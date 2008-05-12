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

namespace Spud{

  enum OptionType{
    SPUD_DOUBLE = 0,
    SPUD_INT    = 1,
    SPUD_NONE   = 2,
    SPUD_STRING = 3,
  };
  
  enum OptionError{
    SPUD_NO_ERROR                = 0,
    SPUD_KEY_ERROR               = 1,
    SPUD_TYPE_ERROR              = 2,
    SPUD_RANK_ERROR              = 3,
    SPUD_SHAPE_ERROR             = 4,
    SPUD_NEW_KEY_WARNING         = -1,
    SPUD_ATTR_SET_FAILED_WARNING = -2,
  };

  typedef char logical_t;

  class OptionManager{
    
    public:
    
      ~OptionManager();

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
            * Sets the name of this element to be that of the root element in the
            * supplied XML file, and adds children to this element corresponding
            * to the data in the XML file.
            */
          void load_options(const std::string& filename);        
          /**
            * Write out this element and all of its children to an XML file with the supplied filename.
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
            * Generate a list containing the names of the children of this element.
            */
          void list_children(const std::string& key, std::deque< std::string >& kids) const;

          /** 
            * Get the child of this element at the supplied key
            * Const version.
            */
          const Option* get_child(const std::string& key) const;
          /**
            * Get the child of this element at the supplied key.
            * Non-const version - checks that the child exists, and if it does finds it with create_child.
            */
          Option* get_child(const std::string& key);

          int get_option(std::vector<logical_t>&) const;
          int get_option(std::vector<double>&) const;
          int get_option(std::vector<int>&) const;
          int get_option(std::string&) const;

          int get_option(std::string, std::vector<logical_t>&) const;
          int get_option(std::string, std::vector<double>&) const;
          int get_option(std::string, std::vector<int>&) const;
          int get_option(std::string, std::string&) const;
          
          int get_option_count(std::string) const;

          size_t get_option_rank() const;
          void get_option_shape(int *) const;
          size_t get_option_size() const;
          OptionType get_option_type() const;

          logical_t have_option(std::string) const;
          
          void print(const std::string& prefix = "") const;
          
          int add_option(std::string);

          int set_option(int, const int*, std::vector<logical_t>&);
          int set_option(std::string, int, const int *, std::vector<logical_t>&);
          
          int set_option(int, const int*, std::vector<double>&);
          int set_option(std::string, int, const int *, std::vector<double>&);

          int set_option(int, const int*, std::vector<int>&);
          int set_option(std::string, int, const int*, std::vector<int>&);

          int set_option(std::string);
          int set_option(std::string, std::string);
          
          /** 
            * Attempt to set the attribute status for this element.
            * Only elements with string data and no children may be marked as attributes.
            */
          logical_t set_is_attribute(const logical_t& is_attribute);
          int set_attribute(std::string, std::string);
          
          int delete_option(std::string);

          void verbose_on();
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
         
          void set_rank_and_shape(int, const int*);
          void set_option_type(OptionType option_type); 
          
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
