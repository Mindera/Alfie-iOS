# Sourced, not run. Snapshot references are recorded on this exact iOS version. A major-only pin is
# not enough: glyph antialiasing differs between minors (26.2 vs 26.4 drifts ~24 px/screen, enough to
# fail precision 1.0). Keep in lockstep with SCAN_DEVICE in fastlane/.env.default. Overridable per
# run, but changing it means re-recording every reference.
SNAPSHOT_OS_VERSION="${SNAPSHOT_OS_VERSION:-26.4}"

# Prints the UDID of an iPhone on iOS $SNAPSHOT_OS_VERSION, or nothing.
pinned_iphone_udid() {
    xcrun simctl list devices available --json | \
        SNAPSHOT_OS_VERSION="$SNAPSHOT_OS_VERSION" /usr/bin/python3 -c '
import json, os, re, sys

wanted = os.environ["SNAPSHOT_OS_VERSION"].replace(".", "-")
for runtime, devices in json.load(sys.stdin)["devices"].items():
    match = re.search(r"iOS-(\d+-\d+)", runtime)
    if not match or match.group(1) != wanted:
        continue
    for device in devices:
        if "iPhone" in device["name"]:
            print(device["udid"])
            sys.exit(0)
'
}

# Prints "<udid> <major.minor>" of an iPhone on the newest available iOS, or nothing.
newest_iphone() {
    xcrun simctl list devices available --json | /usr/bin/python3 -c '
import json, re, sys

best = None
for runtime, devices in json.load(sys.stdin)["devices"].items():
    match = re.search(r"iOS-(\d+)-(\d+)", runtime)
    if not match:
        continue
    version = (int(match.group(1)), int(match.group(2)))
    for device in devices:
        if "iPhone" in device["name"] and (best is None or version > best[0]):
            best = (version, device["udid"], "%s.%s" % (match.group(1), match.group(2)))
if best:
    print("%s %s" % (best[1], best[2]))
'
}

simulator_name() {
    xcrun simctl list devices available | grep -F -- "($1)" | sed -E 's/^[[:space:]]+(.+) \([A-F0-9-]+\).*/\1/'
}

# Prints the UDID of the pinned iPhone, else of the newest one, or nothing.
preferred_iphone_udid() {
    local udid
    udid="$(pinned_iphone_udid)"
    [ -n "$udid" ] || udid="$(newest_iphone | cut -d' ' -f1)"
    echo "$udid"
}

BOOT_TIMEOUT="${BOOT_TIMEOUT:-120}"

# Boots the simulator if needed and waits up to $BOOT_TIMEOUT seconds; bootstatus alone can hang.
wait_for_boot() {
    xcrun simctl bootstatus "$1" -b >/dev/null &
    local pid=$!
    for _ in $(seq 1 "$BOOT_TIMEOUT"); do
        kill -0 "$pid" 2>/dev/null || { wait "$pid"; return; }
        sleep 1
    done
    kill "$pid" 2>/dev/null
    return 1
}

# Snapshot references are recorded in light appearance; the UI launch tests leave the simulator dark.
use_light_appearance() {
    wait_for_boot "$1" && xcrun simctl ui "$1" appearance light
}
