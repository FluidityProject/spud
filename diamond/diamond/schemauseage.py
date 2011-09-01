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

def strip(tag):
  return tag[tag.index("}") + 1:]

def find_fullset(tree):
  """
  Given a schema tree pulls out xpaths for every node.
  """

  def traverse(node):

    if strip(node.tag) == "element":
      fullset.add(tree.getpath(node))

      for child in node:
        traverse(child)
    else:
      for child in node:
        traverse(child)

  start = tree.xpath('/t:grammar/t:start', namespaces={'t': 'http://relaxng.org/ns/structure/1.0'})[0]

  root = start[0]

  fullset = set()
  traverse(root)
  return fullset

def find_useset(tree):
  """
  Given a diamond xml tree pulls out scehama paths for every element and attribute.
  """

  def traverse(node):
    xpath = node.schemaname

    useset.add(xpath)

    for child in node.get_children():
      traverse(child)

  useset = set()
  traverse(tree)
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

def set_to_paths(schema, nameset):
  """
  Converts a set of schemanames to a list of paths.
  """
  def traverse(node):
    if node is start:
      return ""

    tagname = node.get("name") if "name" in node.keys() else strip(node.tag)
    name = None

    for child in node:
      if strip(child.tag) == "attribute":
        if "name" in child.keys() and child.get("name") == "name":
          for grandchild in child:
            if strip(grandchild.tag) == "value":
              name = "[" + grandchild.text + "]"

    return traverse(node.getparent()) + "/" + tagname + (name if name else "")

  start = schema.xpath('/t:grammar/t:start', namespaces={'t': 'http://relaxng.org/ns/structure/1.0'})[0]
  paths = []

  for name in nameset:
    node = schema.xpath(name)[0]
    paths.append(traverse(node))

  return sorted(paths, key = lambda (path): (path.count("/"), path))

if __name__ == "__main__":
  schema = Schema("/home/fjw08/fluidity/schemas/fluidity_options.rng")

  fullset = find_fullset(schema.tree)
  useset = find_useset(schema.read("/home/fjw08/fluidity/examples/top_hat/top_hat_cv.flml"))

  paths = set_to_paths(schema.tree, fullset - useset)
  print "------------"
  for path in sorted(paths, key = lambda (path): (path.count("/"), path)):
    print path

