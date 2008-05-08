import os
import os.path
import sys

import debug

homedir = os.path.expanduser('~')

dirs = [os.path.join(homedir, ".diamond", "schemata")]
if sys.platform != "win32" and sys.platform != "win64":
  dirs.append("/etc/diamond/schemata")

schemata = {}

for dir in dirs:
  try:
    for file in os.listdir(dir):
      handle = open(os.path.join(dir, file))
      schemata[file] = tuple([x.strip() for x in handle])
  except OSError:
    pass

if len(schemata) == 0:
  debug.deprint("Warning: could not find any registered schemata.", 0)

if __name__ == "__main__":
  for key in schemata:
    print "%s: %s" % (key, schemata[key])
