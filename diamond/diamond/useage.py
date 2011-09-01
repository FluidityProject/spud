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

from cStringIO import StringIO
from lxml import etree

from schema import Schema

def find_fullset(tree):
  """
  Given a schema pulls out xpaths for every node.
  """

  node = tree.xpath('/t:grammar/t:start', namespaces={'t': 'http://relaxng.org/ns/structure/1.0'})

  print [n.tag for n in node]

def find_useset(tree):
  """
  Given an xml tree pulls out xpaths for every element and attribute.
  """

  def traverse(useset, node):
    xpath = tree.getpath(node)

    useset.add(xpath)

    for key in node.attrib:
      useset.add(xpath + "/@" + key)

    for child in node:
      traverse(useset, child)

  useset = set()
  traverse(useset, tree.getroot())
  return useset

def find_unusedset(schema, paths):
  """
  Given the path to a scheam and a list of paths to xml files
  find the unused xpaths.
  """

  useset = set()
  for path in paths:
    tree = etree.parse(path)
    useset |= find_useset(tree)

  fullset = find_fullset(etree.parse(schema))

  return fullset - useset

if __name__ == "__main__":
  find_fullset(etree.parse("/home/fjw08/fluidity/schemas/fluidity_options.rng"))

  print find_useset(etree.parse("/home/fjw08/fluidity/examples/top_hat/top_hat_cv.flml"))
