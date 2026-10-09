#!/usr/bin/python3
import http.server
import sys
import urllib.error
import urllib.request

LISTEN_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
UPSTREAM = sys.argv[2] if len(sys.argv) > 2 else "http://127.0.0.1:3000"
SKIPPED_HEADERS = ("host", "content-length", "connection", "accept-encoding")


class Handler(http.server.BaseHTTPRequestHandler):
    def _forward(self):
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length) if length else None
        print(f"HIT {self.client_address[0]} {self.command} {self.path} {length}B", flush=True)
        request = urllib.request.Request(UPSTREAM + self.path, data=body, method=self.command)
        for name, value in self.headers.items():
            if name.lower() not in SKIPPED_HEADERS:
                request.add_header(name, value)
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                status, payload, headers = response.status, response.read(), response.headers
        except urllib.error.HTTPError as error:
            status, payload, headers = error.code, error.read(), error.headers
        print(f"  -> {status} {len(payload)}B", flush=True)
        self.send_response(status)
        content_type = headers.get("Content-Type")
        if content_type:
            self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        self.wfile.write(payload)

    def log_message(self, format, *args):
        pass

    do_GET = _forward
    do_POST = _forward


print(f"Forwarding :{LISTEN_PORT} -> {UPSTREAM}", flush=True)
http.server.ThreadingHTTPServer(("0.0.0.0", LISTEN_PORT), Handler).serve_forever()
