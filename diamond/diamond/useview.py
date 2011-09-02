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

import gobject
import gtk

import schemauseage

RELAXNGNS = "http://relaxng.org/ns/structure/1.0"
RELAXNG = "{" + RELAXNGNS + "}"

class UseView(gtk.Window):
  def __init__(self, schema, path):
    gtk.Window.__init__(self)
    self.__add_controls()
    self.__update(schema, [path])
    self.show_all()

  def __add_controls(self): 
    self.set_title("Unused schema entries")
    self.set_default_size(800, 600)

    scrolledwindow = gtk.ScrolledWindow()
    scrolledwindow.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)

    self.treeview = gtk.TreeView()

    self.treeview.get_selection().set_mode(gtk.SELECTION_SINGLE)

    # Node column
    celltext = gtk.CellRendererText()
    column = gtk.TreeViewColumn("Node", celltext)
    column.set_cell_data_func(celltext, self.set_celltext)

    self.treeview.append_column(column)

    # 0: The node tag
    # 1: Used (0 == Not used, 1 = Child not used, 2 = Used)
    # 3: The xpath
    self.treestore = gtk.TreeStore(gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT)
    self.treeview.set_model(self.treestore)
    self.treeview.set_enable_search(False)

    scrolledwindow.add(self.treeview)
    self.add(scrolledwindow)

  def __set_treestore(self, node, iter = None, type = None):
    if node.tag == RELAXNG + "element":
      tag = schemauseage.node_name(node) + (type if type else "")
      child_iter = self.treestore.append(iter, [tag, 2, self.tree.getpath(node)])
      type = None
    elif node.tag == RELAXNG + "choice":
      tag = "choice" + (type if type else "")
      child_iter = self.treestore.append(iter, [tag, 2, self.tree.getpath(node)])
      type = None
    elif node.tag == RELAXNG + "optional":
      child_iter = iter
      type = " ?"
    elif node.tag == RELAXNG + "oneOrMore":
      child_iter = iter
      type = " +"
    elif node.tag == RELAXNG + "zeroOrMore":
      child_iter = iter
      type = " *"
    else:
      return

    for child in node:
      self.__set_treestore(child, child_iter, type)

  def __set_useage(self, useage):
    def find(xpath, iter = None):
      iter = self.treestore.iter_children(iter)
      while iter:
        if self.treestore.get_value(iter, 2) == xpath:
          return iter
        result = find(xpath, iter)
        if result:
          return result
        iter = self.treestore.iter_next(iter)
      return None

    for xpath in useage:
      iter = find(xpath)
      if iter:
        self.treestore.set_value(iter, 1, 0)

  def __floodfill(self, iter):
    """
    Floodfill the tree with the correct useage.
    """
    useage = self.treestore.get_value(iter, 1)

    child = self.treestore.iter_children(iter)
    while child is not None:
      change = self.__floodfill(child)
      if change != 2:
        self.treestore.set(iter, 1, 1)
      child = self.treestore.iter_next(child)

    return self.treestore.get_value(iter, 1)
 

  def __update(self, schema, paths):
    self.tree = schema.tree
    self.start = self.tree.xpath('/t:grammar/t:start', namespaces={'t': RELAXNGNS})[0]

    self.__set_treestore(self.start[0])
    self.__set_useage(schemauseage.find_unusedset(schema, paths))
    self.__floodfill(self.treestore.get_iter_root())

  def set_celltext(self, column, cell, model, iter):
    tag, useage = model.get(iter, 0, 1)
    cell.set_property("text", tag)

    if useage == 0:
      cell.set_property("foreground", "red")
    elif useage == 1:
      cell.set_property("foreground", "indianred")
    else:
      cell.set_property("foreground", "black")
