#!/bin/bash
# Capture the SeaBearKit screenshot set on the iPhone 17 Pro Max simulator
# (the 6.9-inch 1320x2868 class), then compose the finals.
#
# The Demo app is not a Package.swift target and has no Xcode project, so this
# script builds it directly with swiftc: first the SeaBearKit module as a
# static library for the simulator, then the demo executable against it, then
# a hand-rolled .app bundle (ad-hoc signed — required for simctl launch).
#
# The harness in Sources/Demo/SnapHarness.swift reads SEABEAR_SNAP from the
# launch environment and poses each slide (root menu, or auto-pushes the
# screen via persistentNavigationDestination). The dark slide is captured
# under dark appearance; everything else under light.
#
# Usage: tools/screenshots/shoot.sh   (from the repo root)
set -euo pipefail

DEVICE="iPhone 17 Pro Max"
BUNDLE="dev.seabear.SeaBearKitDemo"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
RAW="$ROOT/AppStore/screenshots/raw"
BUILD="$ROOT/.build/screenshots"
APP="$BUILD/SeaBearKitDemo.app"
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
TARGET="arm64-apple-ios17.0-simulator"

mkdir -p "$RAW"
rm -rf "$BUILD"
mkdir -p "$APP"

echo "building SeaBearKit for the simulator..."
xcrun -sdk iphonesimulator swiftc -sdk "$SDK" -target "$TARGET" -swift-version 6 \
    -parse-as-library -static -emit-library -module-name SeaBearKit \
    -emit-module -emit-module-path "$BUILD/SeaBearKit.swiftmodule" \
    -o "$BUILD/libSeaBearKit.a" \
    $(find "$ROOT/Sources/SeaBearKit" -name '*.swift')

echo "building the demo app..."
xcrun -sdk iphonesimulator swiftc -sdk "$SDK" -target "$TARGET" -swift-version 6 \
    -parse-as-library -I "$BUILD" -L "$BUILD" -lSeaBearKit \
    -o "$APP/SeaBearKitDemo" \
    $(find "$ROOT/Sources/Demo" -name '*.swift')

cat > "$APP/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key><string>SeaBearKitDemo</string>
    <key>CFBundleIdentifier</key><string>$BUNDLE</string>
    <key>CFBundleName</key><string>SeaBearKitDemo</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleShortVersionString</key><string>1.0</string>
    <key>CFBundleVersion</key><string>1</string>
    <key>CFBundleInfoDictionaryVersion</key><string>6.0</string>
    <key>MinimumOSVersion</key><string>17.0</string>
    <key>LSRequiresIPhoneOS</key><true/>
    <key>UIDeviceFamily</key><array><integer>1</integer></array>
    <key>UILaunchScreen</key><dict/>
    <key>DTPlatformName</key><string>iphonesimulator</string>
    <key>DTSDKName</key><string>iphonesimulator</string>
</dict>
</plist>
PLIST
codesign --force --sign - "$APP"

UDID=$(xcrun simctl list devices available | grep -m1 "$DEVICE (" | grep -oE '[A-F0-9-]{36}')
[ -n "$UDID" ] || { echo "no available $DEVICE simulator"; exit 1; }
echo "using $DEVICE ($UDID)"

xcrun simctl boot "$UDID" 2>/dev/null || true
xcrun simctl bootstatus "$UDID" -b >/dev/null

# Marketing chrome: 9:41, full signal.
xcrun simctl ui "$UDID" appearance light
xcrun simctl status_bar "$UDID" override --time "9:41" --batteryState charged \
    --batteryLevel 100 --cellularBars 4 --wifiBars 3

xcrun simctl install "$UDID" "$APP"

capture() {
    SIMCTL_CHILD_SEABEAR_SNAP="$1" xcrun simctl launch "$UDID" "$BUNDLE" >/dev/null
    sleep 4
    xcrun simctl io "$UDID" screenshot "$RAW/$1.png" >/dev/null
    xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
    echo "captured $1"
}

for SNAP in menu depth list form palettes custom; do capture "$SNAP"; done

# The dark slide alone is captured under dark appearance.
xcrun simctl ui "$UDID" appearance dark
capture dark
xcrun simctl ui "$UDID" appearance light

python3 "$ROOT/tools/screenshots/compose.py"
