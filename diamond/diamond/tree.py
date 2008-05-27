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

import base64
import bz2
import copy
import cPickle as pickle
import cStringIO as StringIO
import re
import zlib
from lxml import etree

import debug

class Tree:
  """This class maps pretty much 1-to-1 with an xml tree.
     It is used to represent the options in-core."""

  def __init__(self, name="", schemaname="", attrs={}, children=None, cardinality='', datatype=None, doc=None):
    # name: the element name in the options XML
    # e.g. "fluidity_options"
    self.name = name

    # schemaname: the label given to it in the Xvif parsing of the schema
    # this is necessary to walk the tree to see what possible valid
    # children this node could have
    # e.g. "0:elt" for the root node.
    self.schemaname = schemaname

    # Any children?
    if children is None:
      self.children = copy.copy([])
    else:
      self.children = children

    # The cardinality of a node is
    # how many you must/can have, e.g.
    # "exactly one", "zero or one", "any amount", etc.
    # This is set by Schema.valid_children for candidate
    # nodes in the tree, you see.
    # Possible choices: '' '?' '*' '+'
    # with the usual regex meanings.
    self.cardinality = cardinality

    # Used for Optional or ZeroOrMore
    # trees. False means it is present but inactive.
    # must be set if cardinality is changed!
    self.set_default_active()

    # Any documentation associated with this node?
    self.doc = doc

    # What is the parent of this tree?
    # None means the root node.
    self.parent = None

    # Does this node require attention from the user?
    self.valid = False

    # The datatype that this tree stores and the data stored
    if isinstance(datatype, tuple) and len(datatype) == 1:
      self.datatype = "fixed"
      self.data = datatype[0]
    else:
      self.datatype = datatype
      self.data = None

    # The attributes of the tree
    self.attrs = {}
    for key in attrs.keys():
      if isinstance(attrs[key][0], tuple) and len(attrs[key][0]) == 1:
        self.attrs[key] = ("fixed", attrs[key][0][0])
      else:
        self.attrs[key] = attrs[key]

    self.recompute_validity()

  def set_attr(self, attr, val):
    """Set an attribute."""
    (datatype, curval) = self.attrs[attr]
    (invalid, newdata) = self.valid_data(datatype, val)
    if invalid:
      raise Exception, "invalid data: (%s, %s)" % (datatype, val)
    self.attrs[attr] = (datatype, newdata)
    self.recompute_validity()

  def get_attr(self, attr):
    """Get an attribute."""
    (datatype, curval) = self.attrs[attr]
    return curval

  def set_data(self, data):
    (invalid, data) = self.valid_data(self.datatype, data)
    if invalid:
      raise Exception, "invalid data: (%s, %s)" % (str(self.datatype), data)
    self.data = data
    self.recompute_validity()

  def valid_data(self, datatype, data):
    if datatype is None:
      raise Exception, "datatype is None!"

    elif datatype == "fixed":
      raise Exception, "datatype is fixed!"

    datatypes_to_check = []

    if isinstance(datatype, tuple):
      if isinstance(datatype[0], tuple):
        fixed_values = datatype[0]
      else:
        fixed_values = datatype
      if data in fixed_values:
        return (False, data)
      else:
        if not isinstance(datatype[0], tuple):
          return (True, data)
        datatypes_to_check = list(datatype[1:])
    else:
      datatypes_to_check = [datatype]

    for datatype in datatypes_to_check:
      try:
        tempval = datatype(data)
        if isinstance(tempval, str):
          data = tempval
        return (False, data)
      except:
        pass

    return (True, data)

  def copy(self):
    new_copy = Tree()
    for attr in ["attrs", "name", "schemaname", "doc", "cardinality", "datatype", "parent", "active", "valid"]:
      setattr(new_copy, attr, copy.copy(getattr(self, attr)))

    new_copy.data = self.data
    new_copy.children = copy.copy([])

    return new_copy

  def recompute_validity(self):

    new_valid = True

    # if any children are invalid,
    # we are invalid too
    for child in self.children:
      if child.active is False: continue

      if child.__class__ is Choice:
        child = child.get_current_tree()

      if child.valid is False:
        new_valid = False

    # if any attributes are unset,
    # we are invalid.
    for attr in self.attrs.keys():
      (datatype, val) = self.attrs[attr]
      if not datatype is None and val is None:
        new_valid = False

    # if we're supposed to have data and don't,
    # we are invalid.
    if self.datatype is not None:
      if not hasattr(self, "data"):
        new_valid = False

      if self.data is None:
        new_valid = False

    # so we are valid.
    # in either case, let's let the parent know.
    self.valid = new_valid

    if self.parent is not None:
      self.parent.recompute_validity()

  def find_or_add(self, treelist):
    """Append a child node to this node in the tree.
       If it already exists, make tree point to it."""

    outlist = []

    for tree in treelist:
      new_tree = None
      found = False
      for t in self.children:
        if t.schemaname == tree.schemaname:
          tree = t
          found = True
          break
      if not found:
        tree.set_parent(self)

        self.children.append(tree)
        tree.recompute_validity()

      outlist.append(tree)

      for tree in outlist:
        if tree.cardinality == '+':
          inactive_list = [x for x in outlist if x.schemaname == tree.schemaname and x.active is False]
          if len(inactive_list) > 0: continue
          else:
            new_tree = self.add_inactive_instance(tree)
            outlist.insert(outlist.index(tree)+1, new_tree)

    return outlist

  def write(self, filename):
    try:
      if isinstance(filename, str):
        file = open(filename, "w")
      else:
        file = filename

      xmlTree=etree.tostring(self.write_core(etree.Element(self.name)), pretty_print = True, xml_declaration = True,
    	  encoding="utf8")
    
      file.write(xmlTree)
      file.close()
    except Exception:
       debug.deprint("Could not write XML file %s" % filename, 0)
       sys.exit(1)

  def write_core(self, tree):
    """Write to XML; this is the part that recurses"""
    
    for key in self.attrs.keys():
      val = self.attrs[key]
      output_val = val[1]
      if output_val is not None:
        tree.set(unicode(key), unicode(output_val))
        
    for child in self.children:
      if child.active is True:
        sub_tree=etree.Element(child.name)
        child.write_core(sub_tree)
        tree.append(sub_tree)
      else:
        if child.cardinality == '?':
          comment_buffer = StringIO.StringIO(etree.tostring(child.write_core(etree.Element(self.name))))
          comment_text = ("DIAMOND MAGIC COMMENT (inactive optional subtree %s):\n" % child.schemaname)
          comment_text = comment_text + base64.b64encode(bz2.compress(comment_buffer.getvalue()))
          tree.append(etree.Comment(unicode(comment_text)))
        
    if self.data is not None:
      tree.text=(unicode(self.data))

    return tree

  def pickle(self):
    if hasattr(self, "xmlnode"):
      del self.xmlnode

    return base64.b64encode(bz2.compress(pickle.dumps(self)))

  def unpickle(self, pick):
    return pickle.loads(bz2.decompress(base64.b64decode(pick)))

  def __str__(self):
    s = "name: %s at %s\n" % (self.name, hex(id(self)))
    s = s + "schemaname: %s\n" % self.schemaname
    s = s + "attrs: %s\n" % self.attrs
    s = s + "children: %s\n" % self.children
    if self.parent is not None:
      s = s + "parent: %s %s at %s\n" % (self.parent.__class__, self.parent.name, hex(id(self.parent)))
    else:
      s = s + "parent: %s at %s\n" % (self.parent.__class__, hex(id(self.parent)))
    s = s + "datatype: %s\n" % str(self.datatype)
    s = s + "data: %s\n" % str(self.data)
    s = s + "cardinality: %s\n" % self.cardinality
    s = s + "active: %s\n" % self.active
    s = s + "valid: %s\n" % self.valid
    return s

  def set_default_active(self):
    self.active = True
    if self.cardinality == '?' or self.cardinality == '*':
      self.active = False

  def count_children_by_schemaname(self, schemaname):
    count = len(filter(lambda x: x.schemaname == schemaname, self.children))
    return count

  def delete_child_by_ref(self, ref):
    self.children.remove(ref)

  def add_inactive_instance(self, tree):
    for t in self.children:
      if t.name == tree.name and t.active is False:
        return t

    new_tree = tree.copy()
    new_tree.active = False
    if new_tree.__class__ is Tree:
      new_tree.children = []
    new_tree.parent = tree.parent
    self.children.insert(self.children.index(tree)+1, new_tree)
    return new_tree

  def print_recursively(self, indent=""):
    s = self.__str__()
    debug.dprint(indent + ' ' + s.replace('\n', '\n' + indent + ' '), 0, newline = False)
    debug.dprint("", 0)
    for i in range(len(self.children)):
      if isinstance(self.children[i], Tree):
        self.children[i].print_recursively(indent + ">>")
      elif isinstance(self.children[i], Choice):
        ref = self.children[i].get_current_tree()
        ref.print_recursively(indent + ">>")
      if i < len(self.children) - 1:
        debug.dprint("", 0)

    return

  def add_children(self, schema):
    l = schema.valid_children(self)
    l = self.find_or_add(l)
    for child in self.children:
      child.add_children(schema)

  def matches(self, text, case_sensitive = False):
    if case_sensitive:
      text_re = re.compile(text)
    else:
      text_re = re.compile(text, re.IGNORECASE)

    if not text_re.search(self.name) is None:
      return True

    if not self.doc is None:
      if not text_re.search(self.doc) is None:
        return True

    for key in self.attrs:
      if not text_re.search(key) is None:
        return True
      if not self.get_attr(key) is None:
        if not text_re.search(self.get_attr(key)) is None:
          return True

    if not self.data is None:
      if not text_re.search(self.data) is None:
        return True

    return False

  def get_current_tree(self):
    return self

  def get_possible_names(self):
    return [self.name]

  def set_parent(self, parent):
    self.parent = parent

  def find_tree(self, name):
    if name == self.name:
      return self
    else:
      raise Exception, "ban the bomb"

  def choices(self):
    return [self]

class Choice:
  def __init__(self, l, cardinality=''):
    self.l = l
    self.index = 0
    name = ""
    for choice in l:
      assert choice.__class__ is Tree
      name = name + choice.name + ":"
    name = name[:-1]
    self.name = name
    self.schemaname = name
    self.cardinality = cardinality
    self.parent = None
    self.set_default_active()

  def set_default_active(self):
    self.active = True
    if self.cardinality == '?' or self.cardinality == '*':
      self.active = False

  def choose(self, i):
    self.index = i

  def find_tree(self, name):
    for t in self.l:
      if t.name == name:
        return t

    debug.deprint("self.name == %s" % self.name, 0)
    for choice in self.l:
      debug.deprint("choice.name == %s" % choice.name, 0)
    raise Exception, "No such choice name: %s" % name

  def set_active_choice_by_name(self, name):
    matched = False
    for t in self.l:
      if t.name == name[0:len(t.name)]:
        matched = True
        self.index = self.l.index(t)

    if not matched:
      raise Exception, "no such name found"

    self.recompute_validity()

  def set_active_choice_by_ref(self, ref):
    self.index = self.l.index(ref)
    self.recompute_validity()

  def get_current_tree(self):
    return self.l[self.index]

  def add_children(self, schema):
    return self.get_current_tree().add_children(schema)

  def pickle(self):
    return base64.b64encode(bz2.compress(pickle.dumps(self)))

  def recompute_validity(self):
    self.get_current_tree().recompute_validity()

  def copy(self):
    new_choices = []
    for choice in self.l:
      new_choices.append(choice.copy())

    new_choice = Choice(new_choices)
    for attr in ["index", "name", "schemaname", "cardinality", "active"]:
      setattr(new_choice, attr, copy.copy(getattr(self, attr)))

    new_choice.set_parent(self.parent)
    for choice in new_choice.l:
      choice.children = copy.copy([])

    return new_choice

  def get_possible_names(self):
    return [x.name for x in self.l]

  def set_parent(self, parent):
    self.parent = parent
    for choice in self.l:
      choice.parent = parent

  def write_core(self, tree):
    l = self.l
    for i in range(len(l)):
      if self.index == i:
        l[i].write_core(writer)
      else:
        comment_buffer = StringIO.StringIO(etree.tostring(l[i].write_core(etree.Element(l[i].name))))
        comment_text = ("DIAMOND MAGIC COMMENT (neglected choice subtree %s):\n" % l[i].schemaname)
        comment_text = comment_text + base64.b64encode(bz2.compress(comment_buffer.getvalue()))
        tree.append(etree.Comment(unicode(comment_text)))

  def choices(self):
    return self.l
