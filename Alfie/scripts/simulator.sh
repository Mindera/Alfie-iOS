# Sourced, not run. Snapshot references are recorded on this exact iOS version. A major-only pin is
# not enough: glyph antialiasing differs between minors (26.2 vs 26.4 drifts ~24 px/screen, enough to
# fail precision 1.0). Overridable per run, but changing it means re-recording every reference.
SNAPSHOT_OS_VERSION="${SNAPSHOT_OS_VERSION:-26.4}"
# shellcheck disable=SC2034
NO_PINNED_IPHONE="No iPhone simulator on iOS $SNAPSHOT_OS_VERSION on this runner."

# One simctl listing serves a whole verify.sh run: each call costs 10-80 s on a busy CI runner.
remember_available_devices() {
    ALFIE_SIMULATOR_DEVICES="$(xcrun simctl list devices available --json)"
    export ALFIE_SIMULATOR_DEVICES
}

available_devices() {
    if [ -n "${ALFIE_SIMULATOR_DEVICES:-}" ]; then
        printf '%s\n' "$ALFIE_SIMULATOR_DEVICES"
    else
        xcrun simctl list devices available --json
    fi
}

# Prints the UDID of an iPhone on iOS $SNAPSHOT_OS_VERSION, or nothing.
pinned_iphone_udid() {
    available_devices | \
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
    available_devices | /usr/bin/python3 -c '
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
    available_devices | UDID="$1" /usr/bin/python3 -c '
import json, os, sys

for devices in json.load(sys.stdin)["devices"].values():
    for device in devices:
        if device["udid"] == os.environ["UDID"]:
            print(device["name"])
            sys.exit(0)
'
}

# Prints the UDID of the pinned iPhone, else of the newest one, or nothing.
preferred_iphone_udid() {
    local udid
    udid="$(pinned_iphone_udid)"
    [ -n "$udid" ] || udid="$(newest_iphone | cut -d' ' -f1)"
    echo "$udid"
}

BOOT_TIMEOUT="${BOOT_TIMEOUT:-120}"
BOOT_LOG="/tmp/alfie_simulator_boot.log"

# Starts the boot without waiting, so the simulator settles while something else runs: on a freshly
# booted one the first app launch outlasts Xcode's launch timeout.
start_booting() {
    [ -z "$1" ] || xcrun simctl boot "$1" >/dev/null 2>&1 &
}

# Boots the simulator if needed and waits up to $BOOT_TIMEOUT seconds; bootstatus alone can hang.
wait_for_boot() {
    local started=$SECONDS pid
    : > "$BOOT_LOG"
    xcrun simctl bootstatus "$1" -b > "$BOOT_LOG" 2>&1 &
    pid=$!
    while [ $((SECONDS - started)) -lt "$BOOT_TIMEOUT" ]; do
        if ! kill -0 "$pid" 2>/dev/null; then
            wait "$pid" || break
            echo "⏱️  Simulator ready after a $((SECONDS - started))s wait"
            return 0
        fi
        sleep 1
    done
    kill "$pid" 2>/dev/null
    wait "$pid" 2>/dev/null
    echo "⚠️  Simulator $1 not booted after $((SECONDS - started))s ($(uptime | sed 's/.*load/load/')). Boot progress:"
    sed 's/^/   /' "$BOOT_LOG"
    return 1
}

# Snapshot references are recorded in light appearance; the UI launch tests leave the simulator dark.
use_light_appearance() {
    wait_for_boot "$1" && xcrun simctl ui "$1" appearance light
}
