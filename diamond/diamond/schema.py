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

import debug
import tree
import preprocess

import base64
import bz2
import copy
import sys

import cStringIO

from lxml import etree
from Ft.Xml import Parse
from Ft.Xml.XPath import Evaluate
import Ft.Xml.cDomlette
from Ft.Xml.Domlette import Print, PrettyPrint

class Schema(object):
  def __init__(self, schemafile):
    p = etree.XMLParser(remove_comments=True)
    self.tree = etree.parse(cStringIO.StringIO(preprocess.preprocess(schemafile)), p)

    self.callbacks = {'element': self.cb_element,
                      'documentation': self.cb_documentation,
                      'value': self.cb_value,
                      'attribute': self.cb_attribute,
                      'data': self.cb_data,
                      'optional': self.cb_optional,
                      'zeroOrMore': self.cb_zeroormore,
                      'oneOrMore': self.cb_oneormore,
                      'choice': self.cb_choice,
                      'empty': self.cb_empty,
                      'list': self.cb_list,
                      'group': self.cb_group,
                      'interleave': self.cb_group,
                      'name': self.cb_name,
                      'text': self.cb_text,
		      'anyName' : self.cb_anyname,
		      'nsName' : self.cb_nsname,
		      'except' : self.cb_except}
                      
    self.lost_eles = ""
  
    return

  def element_children(self, element):
    """
    Return a list of the children of the supplied element, following references
    as required.
    """

    children = []
    for child1 in element:
      if self.tag(child1) == "ref":
        if not "name" in child1.attrib.keys():
          debug.deprint("Warning: Encountered reference with no name")
          continue

        name = child1.attrib["name"]
        xpath = self.tree.xpath('/t:grammar/t:define[@name="' + name + '"]',
               namespaces={'t': 'http://relaxng.org/ns/structure/1.0'})

        if len(xpath) == 0:
          debug.deprint("Warning: Schema reference %s not found" % name)
          continue

        node = xpath[0]
        for child2 in self.element_children(node):
          children.append(child2)
      else:
        children.append(child1)

    return children
    
  def choice_children(self, children):
    """
    Collapse all choices within a choice into a single list of (non-choice) children
    """
  
    out_children = []
    for child in children:
      if self.tag(child) == "choice":
        out_children = out_children + self.choice_children(self.element_children(child))
      else:
        out_children.append(child)
        
    return out_children

  def valid_children(self, eid):
    if isinstance(eid, tree.Tree):
      eid = eid.schemaname

    if eid == ":start":
      node = self.tree.xpath('/t:grammar/t:start', namespaces={'t': 'http://relaxng.org/ns/structure/1.0'})[0]
    else:
      node = self.tree.xpath(eid)[0]

    results = []

    for child in self.element_children(node):
      self.append(results, self.to_tree(child))

    return results

  def to_tree(self, element):
    tag = self.tag(element)
    f = self.callbacks[tag]
    facts = {}
    x = f(element, facts)
    return x

  def cb_name(self, element, facts):
    name = element.text
    facts["name"] = name

  def cb_element(self, element, facts):
    newfacts = {}
    if "cardinality" in facts:
      newfacts["cardinality"] = facts["cardinality"]

    if "name" in element.attrib.keys():
      newfacts["name"] = element.attrib["name"]
    else:
      debug.deprint("Warning: Encountered element with no name")
    newfacts['schemaname'] = self.tree.getpath(element)

    for child in self.element_children(element):
      tag = self.tag(child)
      if tag not in ['element', 'optional', 'zeroOrMore', 'oneOrMore']:
        f = self.callbacks[tag]
        x = f(child, newfacts)

    try:
      d = newfacts["datatype"]
      if isinstance(d, tuple):
        new_d = []
        for x in d:
          if not x is None:
            new_d.append(x)
        d = tuple(new_d)
        newfacts["datatype"] = d
        if len(d) == 0:
          newfacts["datatype"] = None
        elif len(d) == 1 and isinstance(d[0], List):
          newfacts["datatype"] = d[0]
        else:
          l_values = []
          l_data   = []
          for x in d:
            if isinstance(x, str):
              l_values.append(x)
            else:
              l_data.append(x)

          if len(l_data) > 1:
            if "name" in element.attrib.keys():
              debug.deprint("Warning: Element %s has multiple datatypes - using first one" % newfacts["name"])
            else:
              debug.deprint("Warning: Unnamed element has multiple datatypes - using first one")

          if len(l_data) > 0:
            if len(l_values) == 0:
              newfacts["datatype"] = l_data[0]
            else:
              newfacts["datatype"] = tuple([tuple(l_values)] + l_data[0])
    except KeyError:
      pass

    return tree.Tree(**newfacts)

  def cb_documentation(self, element, facts):
    facts['doc'] = element.text

  def cb_value(self, element, facts):
    if "datatype" in facts:
      l = list(facts["datatype"])
    else:
      l = []

    l.append(element.text)
    facts["datatype"] = tuple(l)

  def cb_attribute(self, element, facts):
    if not "name" in element.attrib.keys():
      debug.deprint("Warning: Encountered attribute with no name")
      return

    newfacts = {}
    name = element.attrib["name"]

    for child in self.element_children(element):
      tag = self.tag(child)
      f = self.callbacks[tag]
      x = f(child, newfacts)

    if "attrs" not in facts:
      facts["attrs"] = {}

    try:
      datatype = newfacts["datatype"]
    except:
      debug.deprint("Warning: Encountered attribute with no datatype")
      return
    curval = None

    if isinstance(datatype, tuple):
      new_datatype = []
      for x in datatype:
        if not x is None:
          new_datatype.append(x)
      datatype = new_datatype
      if len(datatype) == 0:
        datatype = None
      elif len(datatype) == 1:
        datatype = datatype[0]
        if isinstance(datatype, str):
          curval = datatype
          datatype = 'fixed'
        else:
          curval = None
      else:
        l_values = []
        l_data   = []
        for x in datatype:
          if isinstance(x, str):
            l_values.append(x)
          else:
            l_data.append(x)

        if len(l_data) > 0:
          debug.deprint("Warning: Attribute %s has multiple datatypes - using first one" % name)

        if len(l_data) > 0:
          if len(l_values) == 0:
            datatype = l_data[0]
          else:
            datatype = tuple([tuple(l_values)] + l_data[0])

    facts["attrs"][name] = (datatype, curval)

  def cb_data(self, element, facts):
    if "datatype" in facts:
      if isinstance(facts["datatype"], tuple):
        l = list(facts["datatype"])
      else:
        l = [facts["datatype"]]
    else:
      l = []

    mapping = {'integer': int,
               'float': float,
               'double': float,
               'string': str}

    datatype_name = element.attrib["type"]
    l.append(mapping[datatype_name])
    if len(l) == 1:
      facts["datatype"] = l[0]
    else:
      facts["datatype"] = tuple(l)

  def cb_optional(self, element, facts):
    facts["cardinality"] = '?'
    r = []
    for child in self.element_children(element):
      tag = self.tag(child)
      f = self.callbacks[tag]
      self.append(r, f(child, facts))

    return r

  def cb_zeroormore(self, element, facts):
    facts["cardinality"] = '*'
    r = []
    for child in self.element_children(element):
      tag = self.tag(child)
      f = self.callbacks[tag]
      self.append(r, f(child, facts))

    return r

  def cb_oneormore(self, element, facts):
    facts["cardinality"] = '+'
    r = []
    for child in self.element_children(element):
      tag = self.tag(child)
      f = self.callbacks[tag]
      self.append(r, f(child, facts))

    return r

  def cb_choice(self, element, facts):
    # there are really two cases here.
    # choice between values of elements,
    # and choice between elements

    tagnames = [self.tag(child) for child in element]

    if "value" in tagnames:
      for child in self.element_children(element):
        tag = self.tag(child)
        f = self.callbacks[tag]
        x = f(child, facts)

    else:
      if "schemaname" in facts:
        return

      r = []      
      children = self.choice_children(self.element_children(element))
      
      # bloody simplified RNG
      if len(children) == 2:
        empty = [x for x in children if self.tag(x) == "empty"]
        nonempty = [x for x in children if self.tag(x) != "empty"]
        if len(empty) > 0:
          tag = self.tag(nonempty[0])
          if tag == "oneOrMore":
            return self.cb_oneormore(element, facts)
          else:
            f = self.callbacks[tag]
            return f(element, facts)

      for child in children:
        newfacts = {}
        tag = self.tag(child)
        f = self.callbacks[tag]
        self.append(r, f(child, newfacts))

      return tree.Choice(r, **facts)

  def cb_empty(self, element, facts):
    pass

  def cb_list(self, element, facts):
    newfacts = {}
    for child in self.element_children(element):
      tag = self.tag(child)
      f = self.callbacks[tag]
      f(child, newfacts)

    d = newfacts["datatype"]
    try:
      c = newfacts["cardinality"]
    except KeyError:
      c = ''
      if isinstance(d, tuple):
        c = str(len(d))
        d = d[0]

    l = List(d, c)
    if "datatype" in facts:
      e = list(facts["datatype"])
    else:
      e = []

    e.append(l)
    facts["datatype"] = tuple(e)

  def cb_group(self, element, facts):
    results = []
    for child in self.element_children(element):
      newfacts = {}
      tag = self.tag(child)
      f = self.callbacks[tag]
      self.append(results, f(child, newfacts))

    return results

  def cb_text(self, element, facts):
    if "datatype" in facts:
      if isinstance(facts["datatype"], tuple):
        l = list(facts["datatype"])
      else:
        l = [facts["datatype"]]
    else:
      l = []

    l.append(str)
    if len(l) == 1:
      facts["datatype"] = l[0]
    else:
      facts["datatype"] = tuple(l)

  def cb_anyname(self, element, facts):
    debug.deprint("anyName element found. Yet to handle.", 0)
    sys.exit(1)

  def cb_nsname(self, element, facts):
    debug.deprint("nsName element found. Yet to handle.", 0)
    sys.exit(1)

  def cb_except(self, element, facts):
    debug.deprint("except element found. Yet to handle.", 0)
    sys.exit(1)

  # End of schema processing functions.

  def tag(self, element):
    return element.tag.split('}')[-1]

  def append(self, r, x):
    if x is None:
      return

    if isinstance(x, list):
      for y in x:
        r.append(y)
      return

    r.append(x)

  def read(self, xmlfile):
    doc = Parse(xmlfile)

    self.lost_eles = ""

    datatree = self.valid_children(":start")[0]
    xmlnode  = doc.firstChild
    self.xml_read_merge(datatree, xmlnode)
    self.xml_read_core(datatree, xmlnode, doc)

    if self.lost_eles != "":
      debug.deprint("WARNING: lost XML elements:\n" + self.lost_eles)
      
    return datatree, self.lost_eles

  def xml_read_merge(self, datatree, xmlnode):
    # The datatree has the following set:
    # name, schemaname, doc, cardinality, datatype, parent,
    # attribute datatypes.
    # the xmlnode contains the following information:
    # attribute values, data
    # merge the two.

    datatree.xmlnode = xmlnode
    xmlkeys = [key for (namespace, key) in xmlnode.attributes.keys()]

    if datatree.__class__ is tree.Tree:
      to_set = datatree
    elif datatree.__class__ is tree.Choice:
      if "name" in xmlkeys:
        xmlname = xmlnode.attributes[(None, "name")].value
        have_found = False

        possibles = [choice for choice in datatree.choices() if choice.name == xmlnode.localName]
        # first loop over the fixed-value names
        for choice in possibles:
          if "name" not in choice.attrs:
            continue

          datatype = choice.attrs["name"][0]
          if datatype == 'fixed':
            treename = choice.attrs["name"][1]
            if treename == xmlname:
              have_found = True
              datatree.set_active_choice_by_ref(choice)
              break

        # if we haven't found it, look for a generic name
        if have_found is False:
          for choice in possibles:
            if "name" not in choice.attrs:
              continue

            datatype = choice.attrs["name"][0]
            if datatype != 'fixed':
              have_found = True
              datatree.set_active_choice_by_ref(choice)
              break

      else:
        datatree.set_active_choice_by_name(xmlnode.localName)

      to_set = datatree.get_current_tree()

    # attribute values.
    for key in to_set.attrs.keys():
      if key in xmlkeys:
        try:
          to_set.set_attr(key, xmlnode.attributes[(None, key)].value)
        except:
          pass

    # data.
    for child in xmlnode.childNodes:
      if child.__class__ is Ft.Xml.cDomlette.Text:
        try:
          data = child.data.strip()
          if data != "":
            to_set.set_data(child.data.strip())
            break
        except:
          pass

    to_set.recompute_validity()
    datatree.recompute_validity()

  def xml_read_core(self, datatree, xmlnode, rootdoc):
    """This is the part that recurses, you see."""

    assert len(datatree.children) == 0

    # no information from XML to be had :-/
    if xmlnode is None:
      debug.deprint("Warning: Node %s with no XML information" % datatree.name)
      datatree.add_children(self)
      return

    schemachildren = self.valid_children(datatree)
    xmlchildren    = xmlnode.childNodes

    # bins[schemachild.schemaname] will store the data associated with schemachild
    bins = {}
    for schemachild in schemachildren:
      bins[schemachild.schemaname] = []

    # priority_queue will store the schemachildren, in the order in which
    # they query data from the XML
    priority_queue = []

    # used stores whether the xml node has been used or not
    # we want to detect when xml nodes have been dropped
    # due to schema changes
    used = {}
    for xml in xmlchildren:
      if isinstance(xml, Ft.Xml.cDomlette.Element):
        used[xml] = False

    ###########################################################################################
    # construct the priority queue
    # we treat compulsory nodes first, then descend through the cardinalities
    ###########################################################################################

    # compulsory first.
    for schemachild in schemachildren:
      if schemachild.cardinality == '':
        priority_queue.append(schemachild)

    # then oneormore.
    for schemachild in schemachildren:
      if schemachild.cardinality == '+':
        priority_queue.append(schemachild)

    # then, optional
    for schemachild in schemachildren:
      if schemachild.cardinality == '?':
        priority_queue.append(schemachild)

    # then zeroormore.
    for schemachild in schemachildren:
      if schemachild.cardinality == '*':
        priority_queue.append(schemachild)

    ###########################################################################################
    # initialise the availability data
    # avail[name][xmlnode] records whether xmlnode is available or not
    ###########################################################################################

    avail = {}
    for schemachild in schemachildren:
      for name in schemachild.get_possible_names():
        avail[name] = {}
    for name in avail:
      xml = Evaluate(name, contextNode=xmlnode)
      for xmldata in xml:
        avail[name][xmldata] = True

    ###########################################################################################
    # assign the available xml nodes to the children the schema says should be there
    # in order of priority.
    # xmls[schemachild.schemaname] is the list of xml nodes
    # that schemachild should take
    ###########################################################################################

    xmls = {}

    for schemachild in priority_queue:
      if schemachild.cardinality == '' or schemachild.cardinality == '?':
        for curtree in schemachild.choices():
          name = curtree.name

          have_fixed_name = False
          if "name" in curtree.attrs:
            datatype = curtree.attrs["name"][0]
            if datatype == 'fixed':
              have_fixed_name = True

          if have_fixed_name is False:
            xml = Evaluate(name, contextNode=xmlnode)
          else:
            xml = Evaluate(name + '[@name="%s"]' % curtree.get_attr("name"), contextNode=xmlnode)

          for xmldata in xml:
            if avail[name][xmldata]:
              avail[name][xmldata] = False
              xmls[schemachild.schemaname] = [xmldata]
              break
          if schemachild.schemaname not in xmls:
            if schemachild.cardinality == '':
              xmls[schemachild.schemaname] = copy.deepcopy([])
            elif schemachild.cardinality == '?':
              hidden_xmldata = self.find_hidden_xmldata(schemachild, xmlnode)
              if len(hidden_xmldata) > 0:
                new_xmldata = hidden_xmldata[0]
                xmls[schemachild.schemaname] = [new_xmldata]
                break
              else:
                xmls[schemachild.schemaname] = copy.deepcopy([])

      elif schemachild.cardinality == '*' or schemachild.cardinality == '+':
        xmls[schemachild.schemaname] = copy.deepcopy([])
        for curtree in schemachild.choices():
          name = curtree.name

          have_fixed_name = False
          if "name" in curtree.attrs:
            datatype = curtree.attrs["name"][0]
            if datatype == 'fixed':
              have_fixed_name = True

          if have_fixed_name is False:
            xml = Evaluate(name, contextNode=xmlnode)
          else:
            xml = Evaluate(name + '[@name="%s"]' % curtree.get_attr("name"), contextNode=xmlnode)

          for xmldata in xml:
            if avail[name][xmldata]:
              avail[name][xmldata] = False
              xmls[schemachild.schemaname].append(xmldata)

    ###########################################################################################
    # now that we have assigned the xml nodes, loop through and grab them
    # stuff the tree data in bins[schemachild.schemaname]
    ###########################################################################################

    for schemachild in priority_queue:
      if schemachild.cardinality in ['', '?']:
        child = schemachild.copy()
        child.xmlnode = None
        child.active = True
        if len(xmls[schemachild.schemaname]) == 1:
          xmldata = xmls[schemachild.schemaname][0]
          used[xmldata] = True
          self.xml_read_merge(child, xmldata)
          if xmldata.ownerDocument is not rootdoc:
            self.xml_read_core(child.get_current_tree(), xmldata, xmldata.ownerDocument)
            child.active = False
            child.recurse = False
        else:
          if schemachild.cardinality == '?':
            child.active = False

        bins[schemachild.schemaname] = [child]

      elif schemachild.cardinality in ['*', '+']:
        for xmldata in xmls[schemachild.schemaname]:
          child = schemachild.copy()
          child.active = True
          used[xmldata] = True
          self.xml_read_merge(child, xmldata)
          bins[schemachild.schemaname].append(child)

      if schemachild.cardinality == '+':
        # check that we have at least one.
        count = len(bins[schemachild.schemaname])
        if count == 0:
          child = schemachild.copy()
          child.active = True
          child.xmlnode = None
          bins[schemachild.schemaname] = [child]

      if schemachild.cardinality in ['*', '+']:
        # add an inactive instance
        child = schemachild.copy()
        child.active = False
        child.xmlnode = None
        bins[schemachild.schemaname].append(child)

      # search for neglected choices
      if schemachild.__class__ is tree.Choice and schemachild.cardinality in ['', '?']:
        for child in bins[schemachild.schemaname]:

          if not hasattr(child, "xmlnode"): continue
          if child.xmlnode is None: continue

          current_choice = child.get_current_tree()
          for choice in child.l:
            if choice is current_choice: continue
            hidden_xml = self.find_hidden_xmldata(choice, child.xmlnode.parentNode)
            if len(hidden_xml) > 0:
              new_xmldata = hidden_xml[0]
              self.xml_read_merge(choice, new_xmldata)
              self.xml_read_core(choice, new_xmldata, new_xmldata.ownerDocument)

    ###########################################################################################
    # append the children to the datatree
    # in the order the schema presents them
    # order matters!
    ###########################################################################################

    for schemachild in schemachildren:
      for child in bins[schemachild.schemaname]:
        child.set_parent(datatree)
        datatree.children.append(child)

    ###########################################################################################
    # loop over lost xml nodes
    ###########################################################################################
    for xml in used:
      if used[xml] is False:
        buf = cStringIO.StringIO()
        PrettyPrint(xml, stream=buf, encoding='utf-8')
        s = buf.getvalue()
        buf.close()
        self.lost_eles += s

    ###########################################################################################
    # now do the same for the children
    ###########################################################################################

    for schild in datatree.children:
      if hasattr(schild, "recurse"):
        if schild.recurse is False:
          continue

      if schild.__class__ is tree.Choice:
        child = schild.get_current_tree()
      else:
        child = schild

      child.children = copy.copy([])
      self.xml_read_core(child, schild.xmlnode, rootdoc)

    datatree.recompute_validity()

  def find_hidden_xmldata(self, datatree, xmlnode):
    # Let's look for DIAMOND MAGIC COMMENTs.

    hidden = []
    for xmlchild in xmlnode.childNodes:
      if xmlchild.__class__ is Ft.Xml.cDomlette.Comment:
        data = xmlchild.data
        if datatree.schemaname in data and "DIAMOND MAGIC COMMENT" in data:
          # bingo.
          pickle = data.split('\n')[1]
          doc = Parse(bz2.decompress(base64.b64decode(pickle)))
          for child in doc.childNodes:
            if child.__class__ is Ft.Xml.cDomlette.Element:
              new_xmldata = child
              hidden.append(new_xmldata)
              break

    return hidden

class List:
  def __init__(self, datatype, cardinality=''):
    self.datatype = datatype
    self.cardinality = cardinality

  def __call__(self, val):
    # input to this has to be a string
    val = val.strip()
    if "," in val:
      x = val.split(",")
    else:
      x = val.split(" ")

    if self.cardinality == '+':
      assert len(x) > 0
    elif self.cardinality == '':
      assert len(x) == 1

    try:
      int_cardinality = int(self.cardinality)
      assert len(x) == int_cardinality
    except ValueError:
      pass

    for y in x:
      z = self.datatype(y)

    return " ".join(x)

  def __str__(self):
    return "list of " + str(self.datatype) + " of cardinality: " + self.cardinality

  def __repr__(self):
    return "list of " + str(self.datatype) + " of cardinality: " + self.cardinality
