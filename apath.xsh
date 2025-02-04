#!/usr/bin/env xonsh

from aget import aget, noop

def apath(args, stdin=noop, log=noop):
  code, res = aget($ARGS, log=log)
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

if __name__ == '__main__':
  (code, result) = apath($ARGS, log=print)
  exit(code)