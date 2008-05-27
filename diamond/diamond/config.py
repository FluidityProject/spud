#!/usr/bin/env python

#    This file is part of Diamond.
#
#    Diamond is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Diamond is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Diamond.  If not, see <http://www.gnu.org/licenses/>.

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
      newSchemata = [x.strip() for x in handle]
      if len(newSchemata) != 2:
        debug.deprint("Warning: Found schema registration file \"" + file + "\", but file is improperly formatted - schema type not registered", 0)
        continue
      newSchemata[1] = os.path.expandvars(newSchemata[1])
      schemata[file] = tuple(newSchemata)
      debug.dprint("Registered schema type: " + file)
  except OSError:
    pass

if len(schemata) == 0 and "-s" not in sys.argv:
  debug.deprint("Error: could not find any registered schemata.", 0)
  debug.deprint("Have you registered any in one of the directores %s?" % dirs, 0)
  debug.deprint("To register a schema, place a file in one of those directories, and let its name be the suffix of your language.", 0)
  debug.deprint("The file should have two lines in it:", 0)
  debug.deprint(" A Verbal Description Of The Language Purpose", 0)
  debug.deprint(" /path/to/the/schema/file.rng", 0)
  sys.exit(1)

if __name__ == "__main__":
  for key in schemata:
    print "%s: %s" % (key, schemata[key])
