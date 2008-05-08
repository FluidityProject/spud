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

from lxml import etree
import os
import os.path
import debug
import sys
import copy

def preprocess(schemafile):
  p = etree.XMLParser(remove_comments=True)
  tree = etree.parse(schemafile, p)
  ns = 'http://relaxng.org/ns/structure/1.0'

  #
  # deal with include
  #
  includes = tree.xpath('/t:grammar//t:include', namespaces={'t': ns})

  for include in includes:
    include_parent = include.getparent()
    include_index = list(include_parent).index(include)

    # find the file
    file = None
    filename = include.attrib["href"]
    possible_files = [os.path.join(os.path.dirname(schemafile), filename), filename]
    for possible_file in possible_files:
      try:
        file = open(possible_file)
        break
      except OSError:
        pass

    if file is None:
      debug.deprint("Error: could not located included file %s" % filename, 0)
      sys.exit(1)

    # parse the included xml file and steal all the nodes
    include_tree = etree.parse(file, p)
    nodes_to_take = include_tree.xpath('/t:grammar/*', namespaces={'t': ns})

    # here's where the magic happens:
    for node in nodes_to_take:
      include_parent.insert(include_index, copy.deepcopy(node))

    # now delete the include:
    include_parent.remove(include)

  # deal with combine="interleave"
  # deal with combine="choice"

  return etree.tostring(tree, xml_declaration=True, encoding='utf-8', pretty_print=True)

if __name__ == "__main__":
  import sys
  schemafile = sys.argv[1]
  newfile = schemafile.replace(".rng", ".pp.rng")
  f = open(newfile, "w")
  f.write(preprocess(schemafile))
