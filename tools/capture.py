#!/usr/bin/env python3
"""Shots of SeaBearKit's demo app for a caller outside this repo. `seabear.toml`
at the root names this script, so a tool that keeps pictures elsewhere can ask
for them without knowing how the demo is built.

    tools/capture.py list
    tools/capture.py shoot --out <folder> [--appearance light|dark] [--set KEY=VALUE ...] <shot> ...

`list` prints what can be asked for, as JSON. `shoot` puts each picture in the
folder as <name>-<appearance>.png and writes `capture.json` beside them, an
entry a file: how it was posed, its size, the simulator, and the version and
commit of the library it shows. A folder that already holds one keeps its
other entries.

Every shot is a pose of the SEABEAR_SNAP harness, and the shots are read from
its `Snapshot` enum in Sources/Demo/SnapHarness.swift, so a pose added there
can be asked for here with nothing changed. `--set KEY=VALUE` passes
SEABEAR_<KEY> to the demo. The appearance is the caller's to choose for every
shot: `dark` is the menu in the midnight palette and is meant for
`--appearance dark`, which is how tools/screenshots/shoot.sh takes it.

A picture is kept only when the process it was taken of is still running and
was started as the pose, which is read from that process's environment. A
launch that comes up without it shows the plain menu, which would pass for the
`menu` shot, so it is made again.

`record` is taken and stops: no pose here plays on its own, so there is
nothing to record until one is written.

The simulator and the build are this script's to find. With nothing said it
creates a simulator for the run (an iPhone 17 Pro on the newest iOS here),
builds the library and the demo into a scratch folder with swiftc, as
shoot.sh does, and deletes both when it is done. So it never touches a
standing simulator and leaves nothing in .build. SEABEAR_SIM names a
simulator to use instead, and SEABEAR_APP a built SeaBearKitDemo.app. A named
simulator is left booted.

tools/screenshots/shoot.sh is separate and still makes the marketing set on
the Pro Max, into AppStore/screenshots.
"""
from __future__ import annotations

import datetime
import json
import os
import plistlib
import re
import shutil
import struct
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STANDARD = 1
BUNDLE = "dev.seabear.SeaBearKitDemo"
DEVICE = "iPhone 17 Pro"
TARGET = "arm64-apple-ios17.0-simulator"
HARNESS = ROOT / "Sources/Demo/SnapHarness.swift"
LIBRARY = ROOT / "Sources/SeaBearKit/SeaBearKit.swift"
WAIT = 4.0   # seconds from launch to a settled pose, as shoot.sh waits
TRIES = 3    # launches a pose gets to come up as itself


def stop(message: str) -> None:
    print(f"capture: {message}", file=sys.stderr)
    sys.exit(2)


def tell(message: str) -> None:
    print(f"capture: {message}", file=sys.stderr, flush=True)


def simctl(*args: str, env: dict | None = None) -> subprocess.CompletedProcess:
    return subprocess.run(["xcrun", "simctl", *args], env=env, capture_output=True, text=True)


def poses() -> list[str]:
    """The harness's poses, in its own order: the cases of `enum Snapshot`,
    each by the value SEABEAR_SNAP is matched against."""
    if not HARNESS.is_file():
        stop(f"no harness at {HARNESS}")
    body = re.search(r"enum Snapshot: String \{\n(.*?)\n\s*static let current", HARNESS.read_text(), re.S)
    if not body:
        stop(f"could not read the poses out of {HARNESS}")
    found = []
    for line in body.group(1).splitlines():
        line = line.split("//")[0].strip()
        if not line.startswith("case "):
            continue
        for case in line.removeprefix("case ").split(","):
            name, _, raw = (part.strip() for part in case.partition("="))
            found.append(raw.strip('"') if raw else name)
    if not found:
        stop(f"{HARNESS} has no poses")
    return found


def version() -> str:
    """The library's own version, from the constant it publishes."""
    said = re.search(r'static let version = "([^"]+)"', LIBRARY.read_text())
    if not said:
        stop(f"could not read the version out of {LIBRARY}")
    return said.group(1)


def listing() -> dict:
    return {
        "standard": STANDARD,
        "app": "SeaBearKit",
        "bundle": BUNDLE,
        "appearances": ["light", "dark"],
        "shots": [{"name": name, "variables": {"SNAP": name}, "at": WAIT, "takes": []} for name in poses()],
        "clips": [],
    }


def newest_runtime() -> str:
    runtimes = json.loads(simctl("list", "runtimes", "-j").stdout)["runtimes"]
    fit = [runtime for runtime in runtimes
           if runtime.get("isAvailable")
           and runtime["identifier"].startswith("com.apple.CoreSimulator.SimRuntime.iOS-")
           and any(kind["name"] == DEVICE for kind in runtime.get("supportedDeviceTypes", []))]
    if not fit:
        stop(f"no iOS runtime here makes an {DEVICE}")
    return max(fit, key=lambda runtime: [int(part) for part in runtime["version"].split(".")])["identifier"]


def simulator() -> tuple[str, bool]:
    """The simulator to use, and whether this run created it."""
    named = os.environ.get("SEABEAR_SIM")
    if named:
        return named, False
    made = simctl("create", "SeaBearKit capture", DEVICE, newest_runtime())
    if made.returncode != 0:
        stop(f"could not create a simulator: {made.stderr.strip()}")
    return made.stdout.strip(), True


def describe(udid: str) -> tuple[str, str]:
    """The kind of device a simulator is (not the name it was given) and its iOS."""
    kinds = {kind["identifier"]: kind["name"]
             for kind in json.loads(simctl("list", "devicetypes", "-j").stdout)["devicetypes"]}
    for runtime, found in json.loads(simctl("list", "devices", "-j").stdout)["devices"].items():
        for device in found:
            if device["udid"] == udid:
                said = runtime.rsplit(".", 1)[-1].replace("iOS-", "iOS ").replace("-", ".")
                return kinds.get(device.get("deviceTypeIdentifier"), device["name"]), said
    stop(f"no simulator {udid}")
    raise SystemExit


def compile_swift(what: str, args: list[str]) -> None:
    done = subprocess.run(["xcrun", "-sdk", "iphonesimulator", "swiftc", *args], capture_output=True, text=True)
    if done.returncode != 0:
        stop(f"{what} did not build: {(done.stdout + done.stderr).strip()[-2000:]}")


def build(scratch: Path) -> Path:
    """Build the demo as shoot.sh does. It is not a Package.swift target and
    has no Xcode project, so the library is compiled as a static library for
    the simulator, the demo against it, and the bundle made by hand and
    signed ad hoc, which simctl needs to launch it."""
    tell(f"building the demo into {scratch}")
    sdk = subprocess.run(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"],
                         capture_output=True, text=True).stdout.strip()
    shared = ["-sdk", sdk, "-target", TARGET, "-swift-version", "6", "-parse-as-library"]
    compile_swift("the library", [
        *shared, "-static", "-emit-library", "-module-name", "SeaBearKit",
        "-emit-module", "-emit-module-path", str(scratch / "SeaBearKit.swiftmodule"),
        "-o", str(scratch / "libSeaBearKit.a"),
        *map(str, sorted((ROOT / "Sources/SeaBearKit").rglob("*.swift")))])
    app = scratch / "SeaBearKitDemo.app"
    app.mkdir()
    compile_swift("the demo", [
        *shared, "-I", str(scratch), "-L", str(scratch), "-lSeaBearKit",
        "-o", str(app / "SeaBearKitDemo"),
        *map(str, sorted((ROOT / "Sources/Demo").rglob("*.swift")))])
    with open(app / "Info.plist", "wb") as file:
        plistlib.dump({
            "CFBundleExecutable": "SeaBearKitDemo",
            "CFBundleIdentifier": BUNDLE,
            "CFBundleName": "SeaBearKitDemo",
            "CFBundlePackageType": "APPL",
            "CFBundleShortVersionString": version(),
            "CFBundleVersion": "1",
            "CFBundleInfoDictionaryVersion": "6.0",
            "MinimumOSVersion": "17.0",
            "LSRequiresIPhoneOS": True,
            "UIDeviceFamily": [1],
            "UILaunchScreen": {},
            "DTPlatformName": "iphonesimulator",
            "DTSDKName": "iphonesimulator",
        }, file)
    signed = subprocess.run(["codesign", "--force", "--sign", "-", str(app)], capture_output=True, text=True)
    if signed.returncode != 0:
        stop(f"could not sign the demo: {signed.stderr.strip()}")
    return app


def facts(udid: str, app: Path) -> dict:
    """What every file of a run shares: the library it shows and where it ran."""
    info = plistlib.loads((app / "Info.plist").read_bytes())
    commit = subprocess.run(["git", "-C", str(ROOT), "rev-parse", "--short", "HEAD"],
                            capture_output=True, text=True).stdout.strip()
    dirty = bool(subprocess.run(["git", "-C", str(ROOT), "status", "--porcelain", "--untracked-files=no"],
                                capture_output=True, text=True).stdout.strip())
    device, runtime = describe(udid)
    return {"version": info.get("CFBundleShortVersionString"), "build": info.get("CFBundleVersion"),
            "commit": commit, "dirty": dirty, "device": device, "runtime": runtime}


def png_size(path: Path) -> tuple[int, int]:
    with open(path, "rb") as file:
        head = file.read(24)
    return struct.unpack(">II", head[16:24])


def prepare(udid: str, app: Path, mode: str) -> None:
    """Marketing chrome and the demo installed, then launched once and closed:
    a fresh simulator's first launch is slow, and a pose is shot on a clock."""
    simctl("ui", udid, "appearance", mode)
    simctl("status_bar", udid, "override", "--time", "9:41", "--batteryState", "charged",
           "--batteryLevel", "100", "--cellularBars", "4", "--wifiBars", "3")
    installed = simctl("install", udid, str(app))
    if installed.returncode != 0:
        stop(f"could not install {app}: {installed.stderr.strip()}")
    launch(udid, {"SNAP": "menu"})
    time.sleep(WAIT)
    close(udid)


def close(udid: str) -> None:
    """Terminate the demo and wait until it is gone, so the next launch starts
    a process of its own."""
    simctl("terminate", udid, BUNDLE)
    for _ in range(50):
        if f"UIKitApplication:{BUNDLE}[" not in simctl("spawn", udid, "launchctl", "list").stdout:
            return
        time.sleep(0.1)
    stop("the demo would not close")


def launch(udid: str, variables: dict) -> int:
    """Start the demo with the harness's variables and return its process."""
    env = dict(os.environ)
    for key, value in variables.items():
        env[f"SIMCTL_CHILD_SEABEAR_{key}"] = str(value)
    close(udid)
    started = simctl("launch", udid, BUNDLE, env=env)
    if started.returncode != 0:
        stop(f"the demo did not launch: {started.stderr.strip()}")
    return int(started.stdout.strip().rsplit(":", 1)[-1])


def posed(process: int, pose: str) -> bool:
    """Whether that process is still running and was started as the pose. A
    simulator's app is a process of this Mac, so its environment can be read
    from here."""
    seen = subprocess.run(["ps", "eww", "-o", "command=", "-p", str(process)], capture_output=True, text=True)
    return seen.returncode == 0 and f"SEABEAR_SNAP={pose}" in seen.stdout.split()


def shoot(udid: str, name: str, mode: str, folder: Path, extra: dict) -> dict:
    variables = {"SNAP": name, **extra}
    path = folder / f"{name}-{mode}.png"
    for _ in range(TRIES):
        path.unlink(missing_ok=True)
        process = launch(udid, variables)
        time.sleep(WAIT)
        simctl("io", udid, "screenshot", str(path))
        if posed(process, variables["SNAP"]):
            break
        tell(f"{name} came up without its pose")
    else:
        close(udid)
        path.unlink(missing_ok=True)
        stop(f"{name} did not come up as its pose in {TRIES} launches")
    close(udid)
    if not path.exists():
        stop(f"nothing was shot for {name}")
    width, height = png_size(path)
    return {"name": name, "kind": "shot", "file": path.name, "appearance": mode, "variables": variables,
            "at": WAIT, "width": width, "height": height}


def run(names: list[str], folder: Path, mode: str, extra: dict) -> None:
    known = poses()
    unknown = [name for name in names if name not in known]
    if unknown or not names:
        stop(f"no shot named {', '.join(unknown) or '(none given)'}; `capture.py list` has them")
    folder.mkdir(parents=True, exist_ok=True)
    udid, made = simulator()
    scratch = None
    try:
        simctl("boot", udid)
        subprocess.run(["xcrun", "simctl", "bootstatus", udid, "-b"], capture_output=True)
        app = os.environ.get("SEABEAR_APP")
        if app:
            app = Path(app)
        else:
            scratch = Path(tempfile.mkdtemp(prefix="seabearkit-capture."))
            app = build(scratch)
        if not app.is_dir():
            stop(f"no app at {app}")
        shared = facts(udid, app)
        prepare(udid, app, mode)
        entries = []
        for name in names:
            taken = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            entry = shoot(udid, name, mode, folder, extra)
            entries.append({**entry, "taken": taken, **shared})
            tell(entry["file"])
    finally:
        if made:
            simctl("shutdown", udid)
            simctl("delete", udid)
        else:
            simctl("status_bar", udid, "clear")
        if scratch:
            shutil.rmtree(scratch, ignore_errors=True)
    written = folder / "capture.json"
    kept = []
    if written.exists():
        fresh = {entry["file"] for entry in entries}
        kept = [entry for entry in json.loads(written.read_text()).get("files", []) if entry["file"] not in fresh]
    written.write_text(json.dumps({"standard": STANDARD, "app": "SeaBearKit", "bundle": BUNDLE,
                                   "files": kept + entries}, indent=2) + "\n")
    tell(str(written))


def main() -> None:
    args = sys.argv[1:]
    if args == ["list"]:
        print(json.dumps(listing(), indent=2))
        return
    if not args or args[0] not in ("shoot", "record"):
        stop("usage: capture.py list | shoot --out <folder> <shot> ... "
             "(with --appearance light|dark, --set KEY=VALUE)")
    if args[0] == "record":
        stop("no pose of the demo's plays on its own, so there is nothing to record; "
             "`capture.py list` has the shots")
    rest = args[1:]
    folder, mode, extra, names = None, "light", {}, []
    while rest:
        word = rest.pop(0)
        if word in ("--out", "--appearance", "--set"):
            if not rest:
                stop(f"{word} wants a value")
            value = rest.pop(0)
            if word == "--out":
                folder = Path(value).expanduser().resolve()
            elif word == "--appearance":
                mode = value
            else:
                key, _, said = value.partition("=")
                extra[key.removeprefix("SEABEAR_")] = said
        elif word.startswith("--"):
            stop(f"unknown option {word}")
        else:
            names.append(word)
    if folder is None:
        stop("say where the files go: --out <folder>")
    if mode not in ("light", "dark"):
        stop("--appearance is light or dark")
    run(names, folder, mode, extra)


if __name__ == "__main__":
    main()
