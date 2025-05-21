#!/usr/bin/env xonsh

import sys, os; sys.path.append(os.path.join(os.path.dirname(__file__)))
from common import *

noop = lambda *args: None

def aget(args, stdin=noop, log=noop):
    if (len(args) != 1):
        log("Search not specified or more than one argument was provided")
        return 1, None

    search = args[0]

    packages=$(adb shell "pm list packages --user 0" | grep -i @(search) | cut -d: -f2).strip().split("\n")
    packages=list(filter(lambda x: x, packages))

    if not packages:
        log(f"list packages '{search}': gave nothing")
        return 1, None
    elif len(packages) > 1:
        log(f"list packages '{search}': gave multiple packages:")
        for p in packages:
            log(p)
        return 1, None
    else:
        p = packages[0]
        log(f"Found: {p}")
        return 0, p

def apath(args, stdin=noop, log=noop):
    code, res = aget(args, log=log)
    if (code): return (code, res)

    paths=$(adb shell pm path @(res) --user 0 | cut -d: -f2).strip().split("\n")
    paths=list(filter(lambda x: x, paths))
    if not paths:
        print(f"No paths were found?? for {res}")
        return 1, []
    print("Found paths:")
    for p in paths:
        log(p)
    return 0, paths


def apull(args, stdin=noop, log=noop):



def main():
    log = print
    script = os.path.basename($ARGS[0])
    if (len($ARGS) < 2):
        log(f"Command not provided, format: '{script} <command> [<arg0> [, <arg1>]]'")
        exit(1)

    _, cmd, *args = $ARGS

    func = None
    try:
        func = eval("a"+cmd)
    except NameError as e:
        log(f"Command does not exist: '{cmd}'")
        exit(1)

    (code, result) = func(args, log=print)
    #print(result)
    sys.exit(code)

if __name__ == '__main__': main()