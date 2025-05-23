#!/usr/bin/env xonsh

import sys, os; sys.path.append(os.path.join(os.path.dirname(__file__)))
import argparse, logging
from pathlib import Path

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

def check_adb():
    if not !(adb shell id):
        adb kill-server
        adb start-server
        if not $(adb shell id):
            raise ValueError("Device not connected")


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
    apk-editor @(args)

def apull(pattern, all, dry, name, merge, dir):
    paths, package = apath(pattern)

    if not name: name = package.split(".")[-1]
    dir = os.path.abspath(dir)
    logging.info(f"\nPulling {package}")
    logging.debug(f"Target name is: '{blue(name)}'")
    logging.debug(f"Target directory is: '{blue(dir)}'")

    Path(dir).mkdir(parents=True, exist_ok=True)

    single = not all or len(paths) == 0
    pulled_files = []
    topull = paths if not single else paths[:1]
    for path in topull:
        logging.debug(f"Pulling{' ' if not single else ' single '}{blue(path)}")

        classifier = f"{name}."+path.split("/")[-1]
        target = os.path.join(dir, classifier)

        if single: classifier = classifier.replace("base.", "")
        if not dry: !(adb pull @(path) @(target))

        logging.info(f"Pulled to {blue(target)}")
        pulled_files.append(target)

    if len(paths) > 1 and merge and all:
        merged_name = os.path.join(dir, f"{name}.merged.apk")
        logging.info(f"Merging to {merged_name}")
        if not dry: aedit(["m", "-i", dir, "-o", merged_name])
        pulled_files = [merged_name]

    return pulled_files, paths, package


def _create_parser():
    parser = argparse.ArgumentParser(description="Android reverse engineering tool")
    parser.add_argument("-v", "--verbose", action='store_true', default=False)
    parser.add_argument("-o", "--only-output", action='store_true', default=False)
    subparsers = parser.add_subparsers(dest="command", required=True)

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

    # edit
    c = subparsers.add_parser('edit', help='Edit an apk by apk-editor',add_help=False)

    return parser


def run(cmd, args, rest):
    if cmd == "get":
        return aget(args.package_pattern)
    if cmd == "path":
        return apath(args.package_pattern)
    if cmd == "edit":
        return aedit(rest)
    if cmd == "pull":
        return apull(args.package_pattern, args.all, args.dry, args.name, args.merge, args.dir)

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