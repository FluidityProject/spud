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
import cStringIO as StringIO

import gobject
import gtk

from lxml import etree

import attributewidget
import databuttonswidget
import datawidget
import mixedtree

diff_path = os.path.join( os.path.realpath(os.path.dirname(__file__)), os.pardir, os.pardir, "xmldiff")
sys.path.insert(0, diff_path)

import xmldiff.diff as xmldiff

class DiffView(gtk.Window):

  def __init__(self, path, tree):
    gtk.Window.__init__(self)
    self.__add_controls()

    if os.path.isfile(path):
      filename = path
    else:    
      dialog = gtk.FileChooserDialog(title = "Diff against", 
                                   action = gtk.FILE_CHOOSER_ACTION_OPEN, 
                                   buttons = (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL, gtk.STOCK_OPEN, gtk.RESPONSE_OK))
      if path:
        dialog.set_current_folder(path)
    
      response = dialog.run()
      if response != gtk.RESPONSE_OK:
        dialog.destroy()
        self.destroy()
        return
      
      filename = dialog.get_filename()
      dialog.destroy()
 
    tree1 = etree.parse(filename)
    tree2 = etree.ElementTree(tree.write_core(None))

    editscript = xmldiff.diff(tree1, tree2)
    self.__update(tree1, editscript)
    
    self.show_all()
    
  def __add_controls(self):
    self.set_default_size(800, 600)
    self.set_title("Diff View")
   
    mainvbox = gtk.VBox()

    menubar = gtk.MenuBar()
    edititem = gtk.MenuItem("_Edit")
    menubar.append(edititem)

    agr = gtk.AccelGroup()
    self.add_accel_group(agr)

    self.popup = editmenu = gtk.Menu()
    edititem.set_submenu(editmenu)
    copyitem = gtk.MenuItem("Copy")
    copyitem.connect("activate", self.on_copy)
    key, mod = gtk.accelerator_parse("<Control>C")
    copyitem.add_accelerator("activate", agr, key, mod, gtk.ACCEL_VISIBLE)
    editmenu.append(copyitem)
    
    mainvbox.pack_start(menubar, expand = False)
 
    hpane = gtk.HPaned()
    
    self.treeview = gtk.TreeView()

    self.treeview.get_selection().set_mode(gtk.SELECTION_SINGLE)
    self.treeview.get_selection().connect("changed", self.on_select_row)

    # Node column
    celltext = gtk.CellRendererText()
    column = gtk.TreeViewColumn("Node", celltext)
    column.set_cell_data_func(celltext, self.set_celltext)

    self.treeview.append_column(column)

    # 0: The node tag
    # 1: The attributes dict
    # 2: The value of the node if any
    # 3: The old value of the node
    # 4: "insert", "delete", "update",  ""
    self.treestore = gtk.TreeStore(gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT)
    self.treeview.set_model(self.treestore)
    self.treeview.set_enable_search(False)
    self.treeview.connect("button_press_event", self.on_treeview_button_press)
    self.treeview.connect("popup_menu", self.on_treeview_popup)
    hpane.pack1(self.treeview)
    
    vpane = gtk.VPaned()
    frame = gtk.Frame()
    label = gtk.Label()
    label.set_markup("<b>Attributes</b>")
    frame.set_label_widget(label)
    frame.set_shadow_type(gtk.SHADOW_NONE)

    self.attribview = gtk.TreeView()

    celltext = gtk.CellRendererText()
    keycolumn = gtk.TreeViewColumn("Key", celltext)
    keycolumn.set_cell_data_func(celltext, self.set_cellkey)
    
    self.attribview.append_column(keycolumn)

    celltext = gtk.CellRendererText()
    valuecolumn = gtk.TreeViewColumn("Value", celltext)
    valuecolumn.set_cell_data_func(celltext, self.set_cellvalue)

    self.attribview.append_column(valuecolumn)

    frame.add(self.attribview)
    vpane.pack1(frame)

    frame = gtk.Frame()
    label = gtk.Label()
    label.set_markup("<b>Data</b>")
    frame.set_label_widget(label)
    frame.set_shadow_type(gtk.SHADOW_NONE)
    
    self.dataview = gtk.TextView()
    self.dataview.set_cursor_visible(False)
    self.dataview.set_editable(False)
    self.__create_tags(self.dataview.get_buffer())

    frame.add(self.dataview)
    vpane.pack2(frame)
    
    hpane.pack2(vpane)
    mainvbox.pack_start(hpane)
    self.add(mainvbox)

  def on_treeview_button_press(self, treeview, event):
    pathinfo = treeview.get_path_at_pos(int(event.x), int(event.y))
    if event.button == 3:
      if pathinfo is not None:
        treeview.get_selection().select_path(pathinfo[0])
        self.show_popup(None, event.button, event.time)
        return True

  def popup_location(self, widget, user_data):
    column = self.treeview.get_column(0)
    path = self.treeview.get_selection().get_selected()[1]
    area = self.treeview.get_cell_area(path, column)
    tx, ty = area.x, area.y
    x, y = self.treeview.tree_to_widget_coords(tx, ty)
    return (x, y, True)

  def on_treeview_popup(self, treeview):
    self.show_popup(None, self.popup_location, gtk.get_current_event_time())
    return

  def show_popup(self, func, button, time):
    self.popup.popup( None, None, func, button, time)
    return
 
  def __update(self, tree, editscript):
    self.__set_treestore(tree.getroot())    
    self.__parse_editscript(editscript)
    self.__floodfill(self.treestore.get_iter_root())
    
  def __set_treestore(self, tree, iter = None):
    
    attrib = {}
    for key, value in tree.attrib.iteritems():
      attrib[key] = (value, value, "")
    
    child_iter = self.treestore.append(iter, [tree.tag, attrib, tree.text, tree.text, ""]) 
    for child in tree:
      self.__set_treestore(child, child_iter)
      
  def __parse_editscript(self, editscript):
    print editscript

    for edit in editscript:
      iter, key = self.__get_iter(edit["location"])
      if key:
        attrib = self.treestore.get_value(iter, 1)
        if edit["type"] == "delete":
          attrib[key] = ("", attrib[key][0], "delete")
        elif edit["type"] == "update":
          attrib[key] = (edit["value"], attrib[key][0], attrib[key][2])
        elif edit["type"] == "move":
          attrib[key] = ("", attrib[key][0], "delete")
          __insert(self.__get_iter(edit["value"])[0], key + " " + attrib[key][0], 0)

      else:
        
        if edit["type"] == "insert":
          self.__insert(iter, edit["value"], int(edit["index"]))
        elif edit["type"] == "delete":
          self.treestore.set(iter, 2, "")
          self.treestore.set(iter, 4, "delete")
        elif edit["type"] == "update":
          self.treestore.set(iter, 2, edit["value"])
        elif edit["type"] == "move":
          self.__move(iter, edit["value"], int(edit["index"]))

  def __floodfill(self, iter, parentedit = ""):
    """
    Floodfill the tree with the correct edit types.
    If something has changed below you, "subupdate"
    If your value or attrs has changed "update"
    If insert, all below insert
    If delete, all below delete
    """

    attribs, new, old, edit = self.treestore.get(iter, 1, 2, 3, 4)
    if edit != "insert" and edit != "delete":
      if parentedit == "insert" or parentedit == "delete":
        self.treestore.set(iter, 4, parentedit)
      else:
        update = False
        for key, (valuenew, valueold, valueedit) in attribs.iteritems():
          if valueedit != "":
            update = True
            break
        if new != old:
          update = True

        if update:    
          self.treestore.set(iter, 4, "update")

    child = self.treestore.iter_children(iter)

    while child is not None:
      change = self.__floodfill(child, edit)
      if edit == "" and change != "":
        self.treestore.set(iter, 4, "subupdate")
      child = self.treestore.iter_next(child)

    return self.treestore.get_value(iter, 4)
 
  def __insert(self, iter, value, index):
    if " " in value:
      key, value = value.split(" ")
      attrib = self.treestore.get_value(iter, 1)
      attrib[key] = (value, "", "insert")
    else:
      before = self.treestore.iter_nth_child(iter, index)
      if before:
        self.treestore.insert_before(iter, before, [value, {}, "", "", "insert"]) 
      else:
        self.treestore.append(iter, [value, {}, "", "", "insert"])

  def __move(self, iter, value, index):
    """
    Copy the entire subtree at iter to the path at value[index],
    mark all of iter as deleted, and all of the copy inserted.
    """
    tag, attrib, text = self.treestore.get(iter, 0, 1, 2)
    self.treestore.set(iter, 2, "")
    self.treestore.set(iter, 4, "delete")

    destiter = self.__get_iter(value)[0]

    after = self.treestore.iter_nth_child(destiter, index)
    self.treestore.insert_after(destiter, after, [tag, attrib, text, "", "insert"])

    def move(iterfrom, iterto):
      childfrom = self.treestore.iter_children(iterfrom)

      while childfrom:
        tag, attrib, text = self.treestore.get(childfrom, 0, 1, 2)
        self.treestore.set(iter, 2, "")
        self.treestore.set(childfrom, 4, "delete")
        
        childto = self.treestore.append(iterto, [tag, attrib, text, "", "insert"])
        move(childfrom, childto)

        childfrom = self.treestore.iter_next(childfrom)

    move(iter, destiter)

  def __get_iter(self, path, iter = None):    
    """
    Convert the given XML path to an iter into the treestore.
    """
    
    if iter is None:
      iter = self.treestore.get_iter_first()
      
    tag = self.treestore.get_value(iter, 0)
    
    if path == "/" + tag or path == "/" + tag + "/text()":
      return (iter, None)

    apath = "/" + tag + "/@"
    if path.startswith(apath):
      attrib = self.treestore.get_value(iter, 1)
      for key in attrib.iterkeys():
        if path == apath + key:
          return (iter, key)
      return None
      
    index = path.find("/", 1)
    if index == -1:
      index = len(path)
      
    root = path[:index]
    path = path[index:]
    
    parentiter = self.treestore.iter_parent(iter)
    if parentiter:
      siblingsiter = self.treestore.iter_children(parentiter)
      siblings = []
      while siblingsiter is not None:
        siblingtag = self.treestore.get_value(siblingsiter, 0)
        if siblingtag == tag:
          siblings.append(siblingsiter)
          
        siblingsiter = self.treestore.iter_next(siblingsiter)
      
      if len(siblings) != 1:
        index = "[" + str(siblings.index(iter)) + "]"
      else:
        index = ""
        
      if root != "/" + tag + index:
        return None
    else:
      if root != "/" + tag:
        return None
    
    if path:          
      iter = self.treestore.iter_children(iter)
      
      while iter is not None:
        result = self.__get_iter(path, iter)
        if result:
          return result
        iter = self.treestore.iter_next(iter)
          
      return None
    else:
      return self

  def on_select_row(self, selection):
    """
    Called when a row is selected.
    """
    (model, row) = selection.get_selected()
    if row is None:
      return

    attrib, new, old, edit = model.get(row, 1, 2, 3, 4)
    
    databuffer = self.dataview.get_buffer()
    tag = databuffer.get_tag_table().lookup("tag")
    if new or old: 
      self.__set_textdiff(self.dataview.get_buffer(), old, new)
      tag.set_property("background-set", False)
      tag.set_property("foreground", "black")
    else:
      databuffer.set_text("No data")
      self.__set_cell_property(tag, "")
      tag.set_property("foreground", "grey")
    
    bounds = databuffer.get_bounds()
    databuffer.apply_tag(tag, bounds[0], bounds[1])

    # 0: Key
    # 1: Value
    # 2: Old value
    # 3: "insert", "delete", "update",  ""
 
    attribstore = gtk.TreeStore(gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT, gobject.TYPE_PYOBJECT)

    for key, (new, old, diff) in attrib.iteritems():
      attribstore.append(None, [key, new, old, diff])

    self.attribview.set_model(attribstore)
   
  def __set_textdiff(self, databuffer, old, new):
    text1 = old.splitlines() if old else []
    text2 = new.splitlines() if new else []

    from difflib import Differ
    differ = Differ()
    result = differ.compare(text1, text2)
    result = [line + "\n" for line in result if not line.startswith("? ")]   
   
    databuffer.set_text("") 
    for line in result:
      iter = databuffer.get_end_iter()
      if line.startswith("  "):
        databuffer.insert(iter, line)
      elif line.startswith("+ "):
        databuffer.insert_with_tags_by_name(iter, line, "add")
      elif line.startswith("- "):
        databuffer.insert_with_tags_by_name(iter, line, "rem") 

   
  def __create_tags(self, databuffer):
    databuffer.create_tag("tag")
    add = databuffer.create_tag("add")
    rem = databuffer.create_tag("rem")

    add.set_property("background", "lightgreen")
    rem.set_property("background", "indianred")

  def __set_cell_property(self, cell, edit):
    if edit == "":
      cell.set_property("foreground", "black")
    elif edit == "insert":
      cell.set_property("foreground", "green")
    elif edit == "delete":
      cell.set_property("foreground", "red")
    elif edit == "update":
      cell.set_property("foreground", "blue")
    elif edit == "subupdate":
      cell.set_property("foreground", "cornflowerblue")

  def set_celltext(self, column, cell, model, iter):
  
    tag, text, edit = model.get(iter, 0, 2, 4)

    cell.set_property("text", tag)
    self.__set_cell_property(cell, edit) 

  def set_cellkey(self, column, cell, model, iter):
    
    key, edit = model.get(iter, 0, 3)
    cell.set_property("text", key)
    self.__set_cell_property(cell, edit) 

  def set_cellvalue(self, column, cell, model, iter):
 
    new, old, edit = model.get(iter, 1, 2, 3)
    if edit == "delete":
      cell.set_property("text", old)
    else:
      cell.set_property("text", new)
    self.__set_cell_property(cell, edit) 

  def _get_focus_widget(self, parent):
    """
    Gets the widget that is a child of parent with the focus.
    """
    focus = parent.get_focus_child()
    if focus is None or (focus.flags() & gtk.HAS_FOCUS):
      return focus
    else:
      return self._get_focus_widget(focus)

  def _handle_clipboard(self, widget, signal):
    """
    This finds the currently focused widget.
    If no widget is focused or the focused widget doesn't support 
    the given clipboard operation use the treeview (False), otherwise
    signal the widget to handel the clipboard operation (True).
    """
    widget = self._get_focus_widget(self)

    if widget is None or widget is self.treeview:
      return False

    if gobject.signal_lookup(signal + "-clipboard", widget):
      widget.emit(signal + "-clipboard")
      return True
    else:
      return False

  def __get_treestore(self, iter):

    tag, attrib, text = self.treestore.get(iter, 0, 1, 2)
    
    tree = etree.Element(tag)
    
    for key, (newvalue, oldvalue, edit) in attrib.iteritems():
      tree.attrib[key] = newvalue

    child_iter = self.treestore.iter_children(iter)
    while child_iter:
      child = self.__get_treestore(child_iter)
      tree.append(child)
      child_iter = self.treestore.iter_next(child_iter)
      
    return tree

  def on_copy(self, widget=None):
    if self._handle_clipboard(widget, "copy"):
      return

    (model, row) = self.treeview.get_selection().get_selected()
    if row is None:
      return

    tree = etree.ElementTree(self.__get_treestore(row))

    ios = StringIO.StringIO()
    tree.write(ios, pretty_print = True, xml_declaration = False, encoding = "utf-8")

    clipboard = gtk.clipboard_get()
    clipboard.set_text(ios.getvalue())
    clipboard.store()

    ios.close()
