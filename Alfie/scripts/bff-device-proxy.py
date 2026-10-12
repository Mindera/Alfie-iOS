#!/usr/bin/python3
import http.server
import sys
import urllib.error
import urllib.request

LISTEN_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
UPSTREAM = sys.argv[2] if len(sys.argv) > 2 else "http://127.0.0.1:3000"
HOP_BY_HOP = {"connection", "keep-alive", "transfer-encoding", "te", "trailer", "upgrade", "content-length"}
REQUEST_ONLY = {"host", "accept-encoding"}
SERVER_SET = {"date", "server"}


def is_forwardable(name, extra_skipped=frozenset()):
    lowered = name.lower()
    return lowered not in HOP_BY_HOP and lowered not in extra_skipped and not lowered.startswith("proxy-")


class Handler(http.server.BaseHTTPRequestHandler):
    def _forward(self):
        length = int(self.headers.get("Content-Length") or 0)
        body = self.rfile.read(length) if length else None
        print(f"HIT {self.client_address[0]} {self.command} {self.path} {length}B", flush=True)
        request = urllib.request.Request(UPSTREAM + self.path, data=body, method=self.command)
        for name, value in self.headers.items():
            if is_forwardable(name, REQUEST_ONLY):
                request.add_header(name, value)
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                status, payload, headers = response.status, response.read(), response.headers.items()
        except urllib.error.HTTPError as error:
            status, payload, headers = error.code, error.read(), error.headers.items()
        except OSError as error:
            reason = getattr(error, "reason", error)
            status, payload = 502, f"upstream {UPSTREAM} unreachable: {reason}\n".encode()
            headers = [("Content-Type", "text/plain; charset=utf-8")]
        print(f"  -> {status} {len(payload)}B", flush=True)
        self.send_response(status)
        for name, value in headers:
            if is_forwardable(name, SERVER_SET):
                self.send_header(name, value)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        if self.command != "HEAD":
            self.wfile.write(payload)

    def log_message(self, format, *args):
        pass

    do_GET = do_POST = do_PUT = do_PATCH = do_DELETE = do_HEAD = do_OPTIONS = _forward


print(f"Forwarding :{LISTEN_PORT} -> {UPSTREAM}", flush=True)
print("WARNING: reachable by every device on this network. Trusted Wi-Fi only.", flush=True)
http.server.ThreadingHTTPServer(("0.0.0.0", LISTEN_PORT), Handler).serve_forever()
