#!/usr/bin/env xonsh

from signal import valid_signals
import sys, os;sys.path.append(os.path.join(os.path.dirname(__file__)))
import argparse, logging
from pathlib import Path
import re

noop = lambda *args: None


RED = '\033[91m'
GREEN = '\033[92m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
MAGENTA = '\033[95m'
CYAN = '\033[96m'
WHITE = '\033[97m'
END = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'

blue = lambda x: f"{BLUE}{x}{END}"
bold = lambda x: f"{BOLD}{x}{END}"
red = lambda x: f"{RED}{x}{END}"
yellow = lambda x: f"{YELLOW}{x}{END}"

def check_adb():
    if not !(adb shell id):
        adb kill-server
        adb start-server
        if not ![adb shell id]:
            raise ValueError("Device not connected")

def aname(apkfile):
    package = $(aapt dump badging @(apkfile) | grep "package: name")
    package = package.split("'")[1]

    logging.info(f"Found package name: {blue(package)}")
    return package

def aget(pattern):
    check_adb()
    packages=$(adb shell "pm list packages --user 0" | cut -d: -f2 | grep -i @(pattern)).strip().split("\n")
    packages=list(filter(lambda x: x, packages))

    if not packages:
        raise ValueError(f"Getting no packages for: '{bold(pattern)}'")
    elif len(packages) > 1:
        logging.info(f"Getting multiple packages for '{blue(pattern)}':")
        for p in packages:
            logging.info(p)
    else:
        logging.info(f"Found package: {blue(bold(packages[0]))}")
    return packages

def apath(pattern):
    res = aget(pattern)
    if len(res) > 1: raise ValueError(f"Returned multiple packages, expected one")

    paths=$(adb shell pm path @(res[0]) --user 0 | cut -d: -f2).strip().split("\n")
    paths=list(filter(lambda x: x, paths))
    if not paths: raise ValueError(f"No paths were found?? for {bold(res[0])}")

    logging.info("Found paths:")
    for p in paths: logging.info(blue(p))
    return paths, res[0]


def aedit(args):
    if not ![apk-editor @(args)]:
        raise ValueError(f"Unable to run apk-editor {args}")

def amerge(src, dest_dir, name=""):
    src = os.path.abspath(src)
    Path(dest_dir).mkdir(parents=True, exist_ok=True)

    if not name: name = "merged.apk"
    dest = os.path.abspath(os.path.join(dest_dir, name))
    logging.info(f"Merging {blue(src)} to {blue(dest)}")

    aedit(["m", "-i", src, "-o", dest])
    return dest

def apull(pattern, all, dry, name, merge, dir, index):
    paths, package = apath(pattern)

    if not name: name = package.split(".")[-1]
    dir = os.path.abspath(dir)
    single = not all or len(paths) == 1
    logging.info(f"\nPulling{' ' if not single else ' single('+str(index)+'th) apk of '}{package}")
    logging.debug(f"Target name is: '{blue(name)}'")
    logging.debug(f"Target directory is: '{blue(dir)}'")

    Path(dir).mkdir(parents=True, exist_ok=True)

    pulled_files = []
    topull = paths if not single else [paths[index]]
    for path in topull:
        classifier = f"{name}."+path.split("/")[-1]
        if single: classifier = classifier.replace("base.", "")
        target = os.path.join(dir, classifier)

        if not dry:
            if not ![adb pull @(path) @(target)]:# read return code, to force sync execution
                raise ValueError(f"Unable to pull {path}")

        logging.info(f"Pulled to {blue(target)}")
        pulled_files.append(target)

    if len(paths) > 1 and merge and all:
        logging.info("")
        return [amerge(dir, dir, f"merged.{name}.apk")], paths, package

    return pulled_files, paths, package

def asha_apk(apk):
    logging.info(f"Getting signature for: {blue(apk)}")
    apksigner_output = $(apksigner verify --print-certs @(apk)).splitlines()
    logging.info("\n".join(apksigner_output))

    sha256_match = re.search(r"SHA-256 digest:\s*([a-f0-9]+)", "\n".join(apksigner_output))
    sha256 = sha256_match.group(1) if sha256_match else ""
    logging.info(f"Found sha256: {sha256}")

    formatted_sha256 = ":".join([sha256[i:i+2] for i in range(0, len(sha256), 2)]).upper()
    return formatted_sha256

def asha_package(pattern):
    res = aget(pattern)
    if len(res) > 1: raise ValueError(f"Returned multiple packages, expected one")
    package = res[0]
    logging.info(f"\nGetting signature for: {blue(package)}")
    signature = $(adb shell dumpsys package @(package) | grep Signatures | sed 's/.*\\[//;s/\\].*//').strip()
    if not signature:
        logging.warning(yellow(f"Cannot get the signature of the installed package, let's try downloading and getting signature via apk"))
        # sucks lets try to download apk and get the second part
        target, _, _ = apull(pattern, False, False,  "temp", False, "/tmp", -1) # get last that is smaller
        logging.info("")
        signature = asha_apk(target[0])
        rm @(target)

    return signature

def asha(pattern, apk):
    if pattern: signature = asha_package(pattern)
    else: signature = asha_apk(apk)

    logging.info(f"Found signature: {blue(signature)}")
    return signature

def asign(apks, keystore, env):
    out = []
    for name in apks:
        path = os.path.abspath(name)

        orig = Path(str(path))
        result_apk = str(orig.parent / ("signed."+ orig.name))

        cmd = f"sign --ks-pass env:{env} --ks {keystore} --out {result_apk} {path}"
        logging.debug(f"Running: apksigner {cmd}")
        if not ![apksigner @(cmd.split())]:
            raise ValueError(f"Unable to sign: {path}")

        idsig = Path(f"{result_apk}.idsig")
        if idsig.exists():
            logging.debug(f"Removing {idsig}")
            idsig.unlink()

        logging.info(f"Signed: {blue(result_apk)}")
        out.append(result_apk)
    return out

def _create_parser():
    parser = argparse.ArgumentParser(description="Android reverse engineering tool")
    parser.add_argument("-v", "--verbose", action='store_true', default=False)
    parser.add_argument("-o", "--only-output", action='store_true', default=False)
    subparsers = parser.add_subparsers(dest="command", required=True)

    # name
    c = subparsers.add_parser('name', help='Get package name by given apk')
    c.add_argument('apk_file')

    # get
    c = subparsers.add_parser('get', help='Find apks by name.')
    c.add_argument('package_pattern')

    # path
    c = subparsers.add_parser('path', help='Find paths of a single apk by name.')
    c.add_argument('package_pattern')

    # pull
    c = subparsers.add_parser('pull', help='Pull paths of a single apk by name.')
    c.add_argument("package_pattern")
    c.add_argument("-a","--all", action="store_true", default=True)
    c.add_argument("-s", "--single", dest="all", action="store_false")
    c.add_argument("--dry", action="store_true", default=False)
    c.add_argument("-m", "--merge", action="store_true", default=False)
    c.add_argument("-n", "--name", default="")
    c.add_argument("-d", "--dir", default="./")
    c.add_argument("-i", "--index", type=int, default=0)

    # merge
    c = subparsers.add_parser('merge', help='Merge a folder containing apks to a single apk by apk-editor.')
    c.add_argument('src', default="./")
    c.add_argument('dest', default="./")
    c.add_argument("-n", '--name', default="")

    # sha
    c = subparsers.add_parser('sha', help='Get fingerprint of the package by name or the apk path')
    group = c.add_mutually_exclusive_group(required=True)
    group.add_argument('-p', "--package", default="")
    group.add_argument("-a", "--apk", default="")

    # sign
    c = subparsers.add_parser('sign', help='Get fingerprint of the package by name or the apk path')
    c.add_argument('apks', metavar='N', nargs='*')
    c.add_argument("-k", '--ks', default="{HOME}/.android/debug.keystore".format(HOME=$HOME))
    c.add_argument("-e", '--env', default=f"ANDROID_DEBUG_KEYSTORE_PASS")

    # edit
    c = subparsers.add_parser('edit', help='Edit an apk by apk-editor',add_help=False)

    return parser


def run(cmd, args, rest):
    if cmd == "name":
        return aname(args.apk_file)
    if cmd == "get":
        return aget(args.package_pattern)
    if cmd == "path":
        return apath(args.package_pattern)
    if cmd == "edit":
        return aedit(rest)
    if cmd == "pull":
        return apull(args.package_pattern, args.all, args.dry, args.name, args.merge, args.dir, args.index)
    if cmd == "sha":
        return asha(args.package, args.apk)
    if cmd == "merge":
        return amerge(args.src, args.dest, args.name)
    if cmd == "sign":
        return asign(args.apks, args.ks, args.env)

def print_result(result):
    if isinstance(result, list):
        for i in result:
            print_result(i)
        return
    if isinstance(result, tuple):
        print_result(result[0])
        return
    else:
        print(result)
        return

def main():
    parser = _create_parser()
    args, rest = parser.parse_known_args()

    level = logging.DEBUG if args.verbose else (logging.ERROR if args.only_output else logging.INFO)
    logging.basicConfig(level=level,stream=sys.stdout, format="%(message)s")

    try:
        result = run(args.command, args, rest)
        if args.only_output: print_result(result)
        else: logging.debug(f"\n{blue('Result:')}\n{result}")
    except Exception as e:
        logging.error(red(str(e)))
        sys.exit(1)
if __name__ == '__main__': main()