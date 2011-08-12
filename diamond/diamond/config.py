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

# Here we hard-code a default for flml
# so that users don't have to tweak this to run it.
schemata = {'flml': ('Fluidity markup language', { None: 'http://amcg.ese.ic.ac.uk/svn/fluidity/tags/4.0-release/schemas/fluidity_options.rng'})}

for dir in dirs:
  try:
    for file in os.listdir(dir):
      if file[-1] == "~" or file[0] == ".": #skip files like .nfs0000 
        continue # bloody emacs
      # Skip item gracefully here if there's a problem.
      # This is useful if the schemata files are in a subversion
      # repository and there's pesky .svn folders around.
      try:
        handle = open(os.path.join(dir, file))
      except:
        debug.deprint("Failure to examine entry " + file + " in folder " + dir + ".")
        continue
      lines = [x.strip() for x in handle if x.strip()]
      if len(lines) < 2:
        debug.deprint("Warning: Found schema registration file \"" + file + "\", but file is improperly formatted - schema type not registered", 0)
        continue

      # Expand environment variables in the schema path
      alias = {}
      for i in range(1, len(lines)):
        line = lines[i]

        keyvalue = [x.strip() for x in line.split("=")]
        key, value = ("default", keyvalue[0]) if len(keyvalue) == 1 else keyvalue

        value = os.path.expandvars(value)
        if not os.path.exists(value) and 'http' not in value:
          debug.deprint("Warning: not a valid path: %s" % value)
          debug.deprint("schema type not registered")
          continue

        if key in alias:
          debug.deprint("""alias "%s" already registered, ignoring""" % key)
        else:
          alias[key] = value
          if key == "default":
            alias[None] = value

      schemata[file] = (lines[0], alias)
      debug.dprint("Registered schema type: " + file)
  except OSError:
    pass

if __name__ == "__main__":
  for key in schemata:
    debug.dprint("%s: %s" % (key, schemata[key]), 0)
