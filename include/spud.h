/*  Copyright (C) 2006 Imperial College London and others.
    
    Please see the AUTHORS file in the main source directory for a full list
    of copyright holders.

    Prof. C Pain
    Applied Modelling and Computation Group
    Department of Earth Science and Engineering
    Imperial College London

    C.Pain@Imperial.ac.uk
    
    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation,
    version 2.1 of the License.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
    USA
*/

#ifndef SPUD_H
#define SPUD_H

#include <algorithm>
#include <cassert>
#include <deque>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "tinyxml.h"

#include "spud_enums.h"

namespace Spud{

  typedef char logical_t;

  class OptionManager{
    
    public:

      static OptionManager& get_manager();

      static void load_options(const std::string& filename);      
      static void write_options(const std::string& filename);
      
      static OptionError get_child_name(const std::string& key, const unsigned& index, std::string& child_name); 
      
      static int number_of_children(const std::string& key);
      
      static int option_count(const std::string& key);
      
      static logical_t have_option(const std::string& key);
      
      static OptionError get_option_type(const std::string& key, OptionType& type);      
      static OptionError get_option_rank(const std::string& key, int& rank);
      static OptionError get_option_shape(const std::string& key, std::vector<int>& shape);
      
      static OptionError get_option(const std::string& key, double& option);
      static OptionError get_option(const std::string& key, double& option, const double& default_val);      
      static OptionError get_option(const std::string& key, std::vector<double>& option);
      static OptionError get_option(const std::string& key, std::vector<double>& option, const std::vector<double>& default_val);      
      static OptionError get_option(const std::string& key, std::vector< std::vector<double> >& option);
      static OptionError get_option(const std::string& key, std::vector< std::vector<double> >& option, const std::vector< std::vector<double> >& default_val);
      
      static OptionError get_option(const std::string& key, int& option);
      static OptionError get_option(const std::string& key, int& option, const int& default_val);      
      static OptionError get_option(const std::string& key, std::vector<int>& option);
      static OptionError get_option(const std::string& key, std::vector<int>& option, const std::vector<int>& default_val);      
      static OptionError get_option(const std::string& key, std::vector< std::vector<int> >& option);
      static OptionError get_option(const std::string& key, std::vector< std::vector<int> >& option, const std::vector< std::vector<int> >& default_val);
      
      static OptionError get_option(const std::string& key, std::string& option);
      static OptionError get_option(const std::string& key, std::string& option, const std::string& default_val);
      
      static OptionError add_option(const std::string& key);
      
      static OptionError set_option(const std::string& key, const double& option);      
      static OptionError set_option(const std::string& key, const std::vector<double>& option);      
      static OptionError set_option(const std::string& key, const std::vector< std::vector<double> >& option);
      
      static OptionError set_option(const std::string& key, const int& option);      
      static OptionError set_option(const std::string& key, const std::vector<int>& option);      
      static OptionError set_option(const std::string& key, const std::vector< std::vector<int> >& option);
      
      static OptionError set_option(const std::string& key, const std::string& option);
      
      static OptionError set_option_attribute(const std::string& key, const std::string& option);
      
      static OptionError delete_option(const std::string& key);
    
    private:

      OptionManager();

      OptionManager(const OptionManager& manager);
      
      ~OptionManager();

      OptionManager& operator=(const OptionManager& manager);
      
      static OptionError check_key(const std::string& key);
      
      static OptionError check_rank(const std::string& key, const int& rank);
      
      static OptionError check_type(const std::string& key, const OptionType& type);
      
      static OptionError check_option(const std::string& key, const OptionType& type, const int& rank);
      
      static OptionManager manager;

      class Option{
      
        public:
        
          Option();

          Option(const Option& inOption);

          Option(std::string name);

          ~Option();
         
          const Option& operator=(const Option& inOption); 

          /**
            * Read from an XML file with the given filename.
            * Sets the name of this element to be that of the root element in
            * the supplied XML file, and adds children to this element
            * corresponding to the data in the XML file.
            */
          void load_options(const std::string& filename);        
          /**
            * Write out this element and all of its children to an XML file
            * with the supplied filename.
            */
          void write_options(const std::string& filename) const;

          /**
            * Get the name of this element.
            */
          std::string get_name() const;
          /**
            * Get the attribute status for this element.
            */
          logical_t get_is_attribute() const;

          /**
            * Generate a list containing the names of the children of the
            * element with the supplied key.
            */
          void list_children(const std::string& key, std::deque< std::string >& kids) const;

          /** 
            * Get the child of this element at the supplied key
            * Const version.
            */
          const Option* get_child(const std::string& key) const;
          /**
            * Get the child of this element at the supplied key.
            * Non-const version - checks that the child exists, and if it does
            * finds it with create_child.
            */
          Option* get_child(const std::string& key);
          
          /** 
            * Get the number of elements at the supplied key.
            * Searches un-named elements first, and if this is zero searches
            * (from this highest element in the tree first) named elements.
            */
          int option_count(const std::string& key) const;
          
          /**
            * Test if an element exists at the supplied key.
            */
          logical_t have_option(const std::string& key) const;
          
          /**
            * Get the type of the data in this element, or the __value child if
            * it exists.
            */
          OptionType option_type() const;
          /**
            * Get the rank of the data in this element, or the __value child if
            * it exists.
            */
          size_t option_rank() const;
          /**
            * Get the shape of the data in this element, or the __value child
            * if it exists.
            */
          std::vector<int> option_shape() const;

          /** 
            * Get the double data from this element, or from the __value child
            * if it exists.
            */
          OptionError get_option(std::vector<double>& val) const;
          /** 
            * Get the int data from this element, or from the __value child
            * if it exists.
            */
          OptionError get_option(std::vector<int>& val) const;
          /** 
            * Get the string data from this element, or from the __value child
            * if it exists.
            */
          OptionError get_option(std::string& val) const;

          /** 
            * Get the double data from the supplied key.
            */
          OptionError get_option(const std::string& key, std::vector<double>& val) const;
          /** 
            * Get the int data from the supplied key.
            */
          OptionError get_option(const std::string& key, std::vector<int>& val) const;

          /**
            * Get the string data from the supplied key.
            */
          OptionError get_option(const std::string& key, std::string& val) const;
          
          /** 
            * Find or add a new element at the supplied key.
            */
          OptionError add_option(const std::string& key);
          
          /** 
            * Set the data in the element, or in the __value child if it
            * exists, with the supplied double data.
            */
          OptionError set_option(const std::vector<double>& val, const int& rank, const std::vector<int>& shape);
          /** 
            * Set the data in the element, or in the __value child if it
            * exists, with the supplied int data.
            */
          OptionError set_option(const std::vector<int>& val, const int& rank, const std::vector<int>& shape);
          /** 
            * Set the data in the element, or in the __value child if it
            * exists, with the supplied string data.
            */
          OptionError set_option(const std::string& val);
          
          /** 
            * Set the data at the supplied key with the supplied double data.
            */
          OptionError set_option(const std::string& key, const std::vector<double>& val, const int& rank, const std::vector<int>& shape);
          /** 
            * Set the data at the supplied key with the supplied int data.
            */
          OptionError set_option(const std::string& key, const std::vector<int>& val, const int& rank, const std::vector<int>& shape);
          /** 
            * Set the data at the supplied key with the supplied string data.
            */
          OptionError set_option(const std::string& key, const std::string& val);
          
          /** 
            * Attempt to set the attribute status for this element.
            * Only elements with string data and no children may be marked as
            * attributes.
            */
          logical_t set_is_attribute(const logical_t& is_attribute);
          /** 
            * Set the data at the supplied key with the supplied string data,
            * and mark the element as an attribute.
            */
          OptionError set_attribute(const std::string& key, const std::string& val);
          
          /** 
            * Delete the element at the supplied key.
            */
          OptionError delete_option(const std::string& key);
          
          /** 
            * Print this element to standard output.
            */
          void print(const std::string& prefix = "") const;

          /** 
            * Turn on verbosity for this element (used for debugging only).
            */
          void verbose_on();
          /** 
            * Turn off verbosity for this element.
            */
          void verbose_off();

        private:
        
          /**
            * Tokenize the supplied string
            */
          void tokenize(const std::string& str, std::vector<std::string>& tokens, const std::string& delimiters = " ") const;
          int split_name(const std::string, std::string&, std::string&) const;
          int split_name(const std::string, std::string&, int &index, std::string&) const;
          void split_node_name(std::string&, std::string&) const;
          std::string data_as_string() const;
          
          Option* create_child(std::string);
         
          /** 
            * Set the rank and shape for the data in this element.
            */
          OptionError set_rank_and_shape(const int& rank, const std::vector<int>& shape);
          /** 
            * Set the option type for this element, and delete all data of other option types.
            * If the new option type is not string type and this element is marked as an attribute, unmarks it.
            */
          OptionError set_option_type(const OptionType& option_type);
          
          void parse_node(std::string name, const TiXmlNode *);
          TiXmlElement* to_element() const;
         
          logical_t verbose;
          
          std::string node_name;
          std::multimap<std::string, Option> children;
          
          int rank, shape[2];
          std::vector<double> data_double;
          std::vector<int> data_int;
          std::string data_string;
          
          logical_t is_attribute;
      };
      
      Option* options;
  };
}

#endif
