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
#ifndef OPTION_H
#define OPTION_H

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

enum FLOptionType {OPTION_TYPE_DOUBLE,
		   OPTION_TYPE_INT,
                   OPTION_TYPE_BOOL,
		   OPTION_TYPE_NULL, 
		   OPTION_TYPE_STRING};

typedef char logical_t; // yes - I know about bool but I don't want it

class FLOption{
 public:
  FLOption();
  FLOption(const FLOption&);
  FLOption(std::string, std::string);
  ~FLOption();
  const FLOption& operator=(const FLOption&); 

  std::string get_name() const;
  std::string get_path() const;
  logical_t get_is_attribute() const;
  logical_t set_is_attribute(logical_t is_attribute);

  const FLOption* get_child(std::string) const;
  FLOption* get_child(std::string);

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
  FLOptionType get_option_type() const;

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
  
  FLOption* create_child(std::string);
 
  void set_option_type(FLOptionType option_type); 
  void set_rank_and_shape(int, const int*);
 
  logical_t verbose;
  
  std::string node_path, node_name;
  std::multimap<std::string, FLOption> children;
  
  int rank, shape[2];
  std::vector<logical_t> data_bool;
  std::vector<double> data_double;
  std::vector<int> data_int;
  std::string data_string;
  
  logical_t is_attribute;
};

extern FLOption fluidity_options;
#endif
