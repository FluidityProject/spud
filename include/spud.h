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
    SPUD_INT = 1,
    SPUD_NONE = 2,
    SPUD_STRING = 3,
  };
  
  enum OptionError{
    SPUD_NO_ERROR = 0,
    SPUD_KEY_ERROR = 1,
    SPUD_TYPE_ERROR = 2,
    SPUD_RANK_ERROR = 3,
    SPUD_SHAPE_ERROR = 4,
    SPUD_NEW_KEY_WARNING = 5,
    SPUD_ATTR_SET_FAILED_WARNING = 6,
  };

  typedef char logical_t;

  class OptionManager{
    
    public:
    
      ~OptionManager();

      OptionManager& get_manager();

      void load_options(const std::string& filename);
      
      void write_options(const std::string& filename) const;
      
      OptionError get_child_name(const std::string& key, const unsigned& index, std::string& child_name) const;
      
      int number_of_children(const std::string& key) const;
      
      int option_count(const std::string& key) const;
      
      logical_t have_option(const std::string& key) const;
      
      OptionError get_option_type(const std::string& key, OptionType& type) const;
      
      OptionError get_option_rank(const std::string& key, int& rank) const;
      
      OptionError get_option_shape(const std::string& key, std::vector<int>& shape) const;
      
      OptionError get_option(const std::string& key, double& option) const;
      OptionError get_option(const std::string& key, double& option, const double& default_val) const;
      
      OptionError get_option(const std::string& key, std::vector<double>& option) const;
      OptionError get_option(const std::string& key, std::vector<double>& option, const std::vector<double>& default_val) const;
      
      OptionError get_option(const std::string& key, std::vector< std::vector<double> >& option) const;
      OptionError get_option(const std::string& key, std::vector< std::vector<double> >& option, const std::vector< std::vector<double> >& default_val) const;
      
      OptionError get_option(const std::string& key, int& option) const;
      OptionError get_option(const std::string& key, int& option, const int& default_val) const;
      
      OptionError get_option(const std::string& key, std::vector<int>& option) const;
      OptionError get_option(const std::string& key, std::vector<int>& option, const std::vector<int>& default_val) const;
      
      OptionError get_option(const std::string& key, std::vector< std::vector<int> >& option) const;
      OptionError get_option(const std::string& key, std::vector< std::vector<int> >& option, const std::vector< std::vector<int> >& default_val) const;
      
      OptionError get_option(const std::string& key, std::string& option) const;
      OptionError get_option(const std::string& key, std::string& option, const std::string& default_val) const;
      
      OptionError add_option(const std::string& key);
      
      OptionError set_option(const std::string& key, const double& option);
      
      OptionError set_option(const std::string& key, const std::vector<double>& option);
      
      OptionError set_option(const std::string& key, const std::vector< std::vector<double> >& option);
      
      OptionError set_option(const std::string& key, const int& option);
      
      OptionError set_option(const std::string& key, const std::vector<int>& option);
      
      OptionError set_option(const std::string& key, const std::vector< std::vector<int> >& option);
      
      OptionError set_option(const std::string& key, const std::string& option);
      
      OptionError set_option_attribute(const std::string& key, const std::string& option);
      
      OptionError delete_option(const std::string& key);
    
    private:

      OptionManager();

      OptionManager(const OptionManager& manager);

      OptionManager& operator=(const OptionManager& manager);
      
      OptionError check_key(const std::string& key) const;
      
      OptionError check_rank(const std::string& key, const int& rank) const;
      
      OptionError check_type(const std::string& key, const OptionType& type) const;
      
      OptionError check_option(const std::string& key, const int& rank, const OptionType& type) const;
      
      static OptionManager manager;

    class Option{
    
      public:
      
        Option();

        Option(const Option& inOption);

        Option(std::string name);

        ~Option();
       
        const Option& operator=(const Option& inOption); 

        std::string get_name() const;
        logical_t get_is_attribute() const;
        logical_t set_is_attribute(logical_t is_attribute);

        const Option* get_child(std::string) const;
        Option* get_child(std::string);

        const void *get_option() const;

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

        void list_children(std::string, std::deque< std::string >&) const;
        void load_options_xml(std::string);
        void write_options_xml(std::string) const;
        
        void parse_node(std::string name, const TiXmlNode *);
        TiXmlElement* to_element() const;
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
        
        int set_attribute(std::string, std::string);
        
        int clear_option();
        int clear_option(std::string);
        
        int delete_option(std::string);

        void verbose_on();
        void verbose_off();

      private:
        void Tokenize(const std::string& str,
                      std::vector<std::string>& tokens,
                      const std::string& delimiters = " ") const;
        int split_name(const std::string, std::string&, std::string&) const;
        int split_name(const std::string, std::string&, int &index, std::string&) const;
        void split_node_name(std::string&, std::string&) const;
        std::string data_as_string() const;
        
        Option* create_child(std::string);
       
        void set_option_type(OptionType option_type); 
        void set_rank_and_shape(int, const int*);
       
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
