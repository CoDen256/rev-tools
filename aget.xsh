#!/usr/bin/env xonsh

noop = lambda *args: None

def aget(args, stdin=noop, log=noop):
  if (len(args) != 2):
    log("Search not specified or more than one argument was provided")
    return 1, None

  search = args[1]

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

if __name__ == '__main__':
  (code, result) = aget($ARGS, log=print)
  exit(code)