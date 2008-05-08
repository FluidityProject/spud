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

#include "confdefs.h"

#include <algorithm>
#include <cassert>
#include <deque>
#include <iostream>
#include <map>
#include <sstream>
#include <string>
#include <vector>

#include "tinyxml.h"
#include "Tokenize.h"

namespace Spud{

  enum OptionType{
    OPTION_TYPE_DOUBLE,
	  OPTION_TYPE_INT,
    OPTION_TYPE_BOOL,
	  OPTION_TYPE_NULL, 
	  OPTION_TYPE_STRING
  };

  typedef char logical_t;

  /**
    * Manager of SPUD options.
    * Singleton class handling the options dictionary.
    */
  class OptionManager{
    
    public:
      /**
        * Get the SPUD option manager.
        * \return The SPUD option manager.
        */
      OptionManager& get_manager();

#if 0
      /** Get the manager scope.
        * \return The current option manager scope.
        */
      std::string& get_scope();
      
      /**
        * Return whether the specified option manager scope exists.
        * \param scope The option manager scope to test.
        * \return 1 if the scope exists, 0 if it does not.
        */
      logical_t have_scope(const std::string& scope)
      
      /** Get all current manager scopes.
        * \return All current manager scopes.
        */
      std::vector<std::string>& get_possible_scopes();
      
      /** Add a manager scope.
        * Add the specified scope to the option manager. Any scope name except for an empty string is permitted.
        * \param scope The new option manager scope.
        * \return 0 on success and 1 on failure.
        */
      int delete_scope(const std::string& scope);        
      
      /** Set the manager scope.
        * Sets the option scope (adding the scope if it does not currently exist).
        * \param scope The option manager scope.
        */
      void set_scope(const std::string& scope);
      
      /** Delete the specified manager scope.
        * Deletes the specified scope. If this is the current scope then sets the scope to "". Fails if the specified scope does not exist.
        * \return 0 on success and 1 on failure.
        */
      int delete_scope(const std::string& scope);
#endif
    
    private:
      /**
        * Default constructor.
        * OptionManager is a singleton class, hence this is private.
        */
      OptionManager();
    
      /**
        * Copy constructor - unused.
        */
      OptionManager(const OptionManager& manager);
      
      /**
        * Assignment operator - unused.
        */
      OptionManager& operator=(const OptionManager& manager);
      
      /**
        * The SPUD option manager.
        */
      //static OptionManager manager = OptionManager();

    /**
      * Options dictionary class.
      * A class defining an option element with specified name, path and children.
      */
    class Option{
    
      public:
      
        /**
          * Default constructor.
          * Construct a non-verbose non-attribute empty element with no defined path or name.
          */
        Option();
        /**
          * Copy constructor.
          * Construct a new element as a copy of the supplied element.
          * \param inOption Option to be copied
          */
        Option(const Option& inOption);
        /**
          * Option constructor
          * Construct a non-verbose non-attribute empty element with the given option path and name.
          * \param The option path
          * \param The option name
          */
        Option(std::string path, std::string name);
        /**
          * Option destructor.
          */
        ~Option();
       
        /**
          * Assignment operator.
          * Make this element a copy of the supplied element.
          * \param inOption Option to be copied.
          */    
        const Option& operator=(const Option& inOption); 

        std::string get_name() const;
        std::string get_path() const;
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
        void print() const;
        
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
      
        int split_name(const std::string, std::string&, std::string&) const;
        int split_name(const std::string, std::string&, int &index, std::string&) const;
        void split_node_name(std::string&, std::string&) const;
        std::string data_as_string() const;
        
        Option* create_child(std::string);
       
        void set_option_type(OptionType option_type); 
        void set_rank_and_shape(int, const int*);
       
        logical_t verbose;
        
        std::string node_path, node_name;
        std::multimap<std::string, Option> children;
        
        int rank, shape[2];
        std::vector<logical_t> data_bool;
        std::vector<double> data_double;
        std::vector<int> data_int;
        std::string data_string;
        
        logical_t is_attribute;
      };
      
    /**
      * The options dictionary.
      */
    Option options;
  };
}

#endif
