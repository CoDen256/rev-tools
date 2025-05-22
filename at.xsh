#!/usr/bin/env xonsh

import sys, os; sys.path.append(os.path.join(os.path.dirname(__file__)))
import argparse, logging

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
        raise ValueError(f"Getting no packages for: {BOLD}'{pattern}'")
    elif len(packages) > 1:
        logging.info(f"Getting package {BLUE}'{pattern}'{END}: gave multiple packages:")
        for p in packages:
            logging.info(p)
    else:
        logging.info(f"Found package: {BLUE}{BOLD}{packages[0]}{END}")
    return packages

def apath(pattern):
    res = aget(pattern)
    if len(res) > 1: raise ValueError(f"Returned multiple packages, expected one")

    paths=$(adb shell pm path @(res[0]) --user 0 | cut -d: -f2).strip().split("\n")
    paths=list(filter(lambda x: x, paths))
    if not paths: raise ValueError(f"No paths were found?? for {BOLD}{res[0]}")

    logging.info("Found paths:")
    for p in paths: logging.info(BLUE+p+END)
    return paths


def aedit(args, stdin=noop, log=noop):
    apk-editor @(args)

def apull(
        search: str = "",
        all: bool = True,
        v: bool = False,
        dry: bool = False,
        name: str = "",
):
    parser = argparse.ArgumentParser()
    parser.add_argument("search", nargs="?", default="")
    parser.add_argument("--all", action="store_true", default=True)
    parser.add_argument("--no-all", dest="all", action="store_false")
    parser.add_argument("-v", action="store_true")
    parser.add_argument("--dry", action="store_true")
    parser.add_argument("--name", default="")

    # _, package = aget(search)
    # _, paths = apath(search)
    #
    # if not paths:
    #     echo "No paths found"
    #     return
    #
    # if not name:
    #     name = package.split(".")[-1]
    #
    # if all:
    #     pulled_files = []
    #     for p in paths:
    #         if not p:
    #             echo "path is invalid"
    #             continue
    #
    #         if v:
    #             echo f"Pulling {p}"
    #
    #         n = p.split("/")[-1]
    #         if n == "base.apk":
    #             n = "base.apk"
    #         else:
    #             n = f"{name}.{n}"
    #
    #         if not dry:
    #             !adb pull @(p) @(f"./{n}")
    #
    #         echo f"Pulled {n}"
    #         pulled_files.append(n)
    #
    #     if len(paths) > 1:
    #         merged_name = f"{name}.m.apk"
    #         echo f"Merging to {merged_name}"
    #         !aedit.ps1 m -i ./ -o @(merged_name)
    #         echo merged_name
    #     else:
    #         echo pulled_files[0]
    # else:
    #     p = paths[0]
    #     if v:
    #         echo f"Pulling {p}"
    #
    #     output_name = f"{name}.base.apk"
    #     if not dry:
    #         !adb pull @(p) @(f"./{output_name}")
    #
    #     echo f"Pulled {output_name}"
    #     echo output_name


def _create_parser():
    parser = argparse.ArgumentParser(description="Android reverse engineering tool")
    parser.add_argument("-v", "--verbose", action='store_true', default=False)
    subparsers = parser.add_subparsers(dest="command", required=True)

    # get
    c = subparsers.add_parser('get', help='Find apks by name.')
    c.add_argument('package_pattern')

    # path
    c = subparsers.add_parser('path', help='Find paths of a single apk by name.')
    c.add_argument('package_pattern')

    # pull
    c = subparsers.add_parser('pull', help='Pull a single apk by name and merge it.')
    c.add_argument('search', nargs='?', default="")
    c.add_argument('--all', action='store_true', default=True)
    c.add_argument('--no-all', dest='all', action='store_false')
    c.add_argument('-v', action='store_true')

    return parser


def run(cmd, args):
    if cmd == "get":
        return aget(args.package_pattern)
    if cmd == "path":
        return apath(args.package_pattern)

def main():
    log = print
    parser = _create_parser()
    args = parser.parse_args()

    level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(level=level,stream=sys.stdout, format="%(message)s")

    try:
        result = run(args.command, args)
        logging.debug(result)
    except Exception as e:
        logging.error(RED+str(e)+END)
        sys.exit(1)
if __name__ == '__main__': main()