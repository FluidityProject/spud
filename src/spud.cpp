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

#include "spud.h"

using namespace std;

using namespace Spud;

// OptionManager CLASS METHODS

// PUBLIC METHODS

OptionManager::~OptionManager(){
  delete options;

  return;
}

OptionManager& OptionManager::get_manager(){
  return manager;
}

void OptionManager::load_options(const string& filename){
  manager.options->load_options(filename);
  
  return;
}

void OptionManager::write_options(const string& filename){
  manager.options->write_options(filename);
  
  return;
}

OptionError OptionManager::get_child_name(const string& key, const unsigned& index, string& child_name){
  deque<string> kids;
  manager.options->list_children(key, kids);
  if(kids.size() < index){
    return SPUD_KEY_ERROR;
  }
  
  child_name = kids[index];

  return SPUD_NO_ERROR;
}

int OptionManager::number_of_children(const string& key){
  deque<string> kids;
  manager.options->list_children(key, kids);
  
  return kids.size();
}

int OptionManager::option_count(const string& key){
  return manager.options->get_option_count(key);
}

logical_t OptionManager::have_option(const string& key){
  return manager.options->have_option(key);
}
    
OptionError OptionManager::get_option_type(const string& key, OptionType& type){
  Option* child = manager.options->get_child(key);
  if(child == NULL){
    return SPUD_KEY_ERROR;
  }
  
  type = child->get_option_type();
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option_rank(const string& key, int& rank){
  Option* child = manager.options->get_child(key);
  if(child == NULL){
    return SPUD_KEY_ERROR;
  }
  
  rank = child->get_option_rank();
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option_shape(const string& key, vector<int>& shape){
  Option* child = manager.options->get_child(key);
  if(child == NULL){
    return SPUD_KEY_ERROR;
  }
  
  int shape_handle[2];
  child->get_option_shape(shape_handle);

  int rank;
  OptionError rank_err = get_option_rank(key, rank);
  if(rank_err != SPUD_NO_ERROR){
    return rank_err;
  }
  
  shape.clear();
  for(int i = 0;i < rank;i++){
    shape.push_back(shape_handle[i]);
  }

  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, double& option){
  OptionError check_err = check_option(key, 0, SPUD_DOUBLE);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<double> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(option_handle.size() != 1){
    return SPUD_RANK_ERROR;
  }
  
  option = option_handle[0];
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, double& option, const double& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }
  
  return get_option(key, option);
}

OptionError OptionManager::get_option(const string& key, vector<double>& option){ 
  OptionError check_err = check_option(key, 1, SPUD_DOUBLE);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<double> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  option = option_handle;
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, vector<double>& option, const vector<double>& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }
  
  return get_option(key, option);
}

OptionError OptionManager::get_option(const string& key, vector< vector<double> >& option){
  OptionError check_err = check_option(key, 2, SPUD_DOUBLE);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<int> shape;
  OptionError shape_err = get_option_shape(key, shape);
  if(shape_err != SPUD_NO_ERROR){
    return shape_err;
  }
  
  vector<double> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  option.clear();
  for(int i = 0;i < shape[0];i++){
    option.push_back(vector<double>(shape[1]));
    for(int j = 0;i < shape[1];j++){
      option[i][j] = option_handle[(i * shape[0]) + j];
    }
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, vector< vector<double> >& option, const vector< vector<double> >& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }

  return get_option(key, option);
}
      
OptionError OptionManager::get_option(const string& key, int& option){
  OptionError check_err = check_option(key, 0, SPUD_INT);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<int> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(option_handle.size() != 1){
    return SPUD_RANK_ERROR;
  }
  
  option = option_handle[0];
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, int& option, const int& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }
  
  return get_option(key, option);
}

OptionError OptionManager::get_option(const string& key, vector<int>& option){
  OptionError check_err = check_option(key, 1, SPUD_INT);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<int> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  option = option_handle;
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, vector<int>& option, const vector<int>& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }
  
  return get_option(key, option);
}

OptionError OptionManager::get_option(const string& key, vector< vector<int> >& option){
  OptionError check_err = check_option(key, 2, SPUD_INT);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }

  vector<int> shape;
  OptionError shape_err = get_option_shape(key, shape);
  if(shape_err != SPUD_NO_ERROR){
    return shape_err;
  }
  
  vector<int> option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  option.clear();
  for(int i = 0;i < shape[0];i++){
    option.push_back(vector<int>(shape[1]));
    for(int j = 0;i < shape[1];j++){
      option[i][j] = option_handle[(i * shape[0]) + j];
    }
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, vector< vector<int> >& option, const vector< vector<int> >& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }

  return get_option(key, option);
}

OptionError OptionManager::get_option(const string& key, string& option){
  OptionError check_err = check_option(key, 1, SPUD_STRING);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }
  
  string option_handle;
  int get_ret = manager.options->get_option(key, option_handle);
  if(get_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  option = option_handle;
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::get_option(const string& key, string& option, const string& default_val){
  if(!have_option(key)){
    option = default_val;
    return SPUD_NO_ERROR;
  }
  
  return get_option(key, option);
}

OptionError OptionManager::add_option(const string& key){
  logical_t new_key = !have_option(key);
  
  int add_ret = manager.options->add_option(key);
  if(add_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::set_option(const string& key, const double& option){
  logical_t new_key = !have_option(key);
  
  vector<double> option_handle;
  option_handle.push_back(option);
  int shape[2];
  shape[0] = -1;  shape[1] = -1;
  int set_ret = manager.options->set_option(key, 0, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}
      
OptionError OptionManager::set_option(const string& key, const vector<double>& option){
  logical_t new_key = !have_option(key);
  
  vector<double> option_handle = option;
  int shape[2];
  shape[0] = option.size();  shape[1] = -1;
  int set_ret = manager.options->set_option(key, 1, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}
      
OptionError OptionManager::set_option(const string& key, const vector< vector<double> >& option){
  logical_t new_key = !have_option(key);
  
  vector<double> option_handle;
  for(size_t i = 0;i < option.size();i++){
    if(i > 0 and option[i].size() != option[0].size()){
      return SPUD_SHAPE_ERROR;
    }
    for(size_t j = 0;j < option[i].size();j++){
      option_handle.push_back(option[i][j]);
    }
  }
  int shape[2];
  shape[0] = option.size();
  if(option.size() == 0){
    shape[1] = 0;
  }else{
    shape[1] = option[0].size();
  }
  int set_ret = manager.options->set_option(key, 1, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}
      
OptionError OptionManager::set_option(const string& key, const int& option){
  logical_t new_key = !have_option(key);
  
  vector<int> option_handle;
  option_handle.push_back(option);
  int shape[2];
  shape[0] = -1;  shape[1] = -1;
  int set_ret = manager.options->set_option(key, 0, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}
      
OptionError OptionManager::set_option(const string& key, const vector<int>& option){
  logical_t new_key = !have_option(key);
  
  vector<int> option_handle = option;
  int shape[2];
  shape[0] = -1;  shape[1] = -1;
  int set_ret = manager.options->set_option(key, 1, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}
      
OptionError OptionManager::set_option(const string& key, const vector< vector<int> >& option){
  logical_t new_key = !have_option(key);
  
  vector<int> option_handle;
  for(size_t i = 0;i < option.size();i++){
    if(i > 0 and option[i].size() != option[0].size()){
      return SPUD_SHAPE_ERROR;
    }
    for(size_t j = 0;j < option[i].size();j++){
      option_handle.push_back(option[i][j]);
    }
  }
  int shape[2];
  shape[0] = option.size();
  if(option.size() == 0){
    shape[1] = 0;
  }else{
    shape[1] = option[0].size();
  }
  int set_ret = manager.options->set_option(key, 2, shape, option_handle);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }else if(new_key){
    return SPUD_NEW_KEY_WARNING;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::set_option(const string& key, const string& option){
  int set_ret = manager.options->set_option(key, option);
  if(set_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::set_option_attribute(const string& key, const string& option){
  OptionError set_err = set_option(key, option);
  logical_t is_attribute = manager.options->set_is_attribute(true);
  if(set_err != SPUD_NO_ERROR){
    return set_err;
  }else if(!is_attribute){
    return SPUD_ATTR_SET_FAILED_WARNING;
  }
  
  return SPUD_NO_ERROR;
}

logical_t OptionManager::Option::set_is_attribute(const logical_t& is_attribute){
  if(verbose)
    cout << "void OptionManager::Option::set_is_attribute(const logical_t& is_attribute = " << is_attribute << ")\n";
  if(children.size() == 0 and get_option_type() == SPUD_STRING){
    this->is_attribute = is_attribute;
  }
  
  return this->is_attribute;
}
      
OptionError OptionManager::delete_option(const string& key){
  int del_ret = manager.options->delete_option(key);
  if(del_ret != 0){
    return SPUD_KEY_ERROR;
  }
  
  return SPUD_NO_ERROR;
}

// PRIVATE METHODS

OptionManager::OptionManager(){
  options = new OptionManager::Option();

  return;
}

OptionManager::OptionManager(const OptionManager& manager){
  cerr << "OptionManager copy constructor cannot be called" << endl;
  exit(-1);
}

OptionManager& OptionManager::operator=(const OptionManager& manager){
  cerr << "OptionManager assignment operator cannot be called" << endl;
  exit(-1);
}

OptionError OptionManager::check_key(const string& key){
  if(!have_option(key)){
    return SPUD_KEY_ERROR;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::check_rank(const string& key, const int& rank){
  int rank_handle;
  OptionError rank_err = get_option_rank(key, rank_handle);
  if(rank_err != SPUD_NO_ERROR){
    return rank_err;
  }else if(rank_handle != rank){
    return SPUD_RANK_ERROR;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::check_type(const string& key, const OptionType& type){
  OptionType type_handle;
  OptionError type_err = get_option_type(key, type_handle);
  if(type_err != SPUD_NO_ERROR){
    return type_err;
  }else if(type_handle != type){
    return SPUD_TYPE_ERROR;
  }
  
  return SPUD_NO_ERROR;
}

OptionError OptionManager::check_option(const string& key, const int& rank, const OptionType& type){
  OptionError check_err;
  check_err = check_key(key);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }
  check_err = check_rank(key, rank);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }
  check_err = check_type(key, type);
  if(check_err != SPUD_NO_ERROR){
    return check_err;
  }  

  return SPUD_NO_ERROR;
}


// End OptionManager CLASS METHODS

// OptionManager::Option CLASS METHODS

// PUBLIC METHODS

OptionManager::Option::Option(){
  verbose_off();
  set_rank_and_shape(-1, NULL);
  is_attribute = false;
  
  return;
}

OptionManager::Option::Option(const OptionManager::Option& inOption){
  *this = inOption;
  
  return;
}

OptionManager::Option::Option(string name){
  verbose_off();
  node_name = name;
  set_rank_and_shape(-1, NULL);
  is_attribute = false;
  
  return;
}

OptionManager::Option::~Option(){
  return;
}

const OptionManager::Option& OptionManager::Option::operator=(const OptionManager::Option& inOption){
  verbose = inOption.verbose;
  if(verbose)
    cout << "const OptionManager::Option& OptionManager::Option::operator=(const OptionManager::Option& inOption)\n";
  
  node_name = inOption.node_name;
  children = inOption.children;

  data_double = inOption.data_double;
  data_int = inOption.data_int;
  data_string = inOption.data_string;
  set_rank_and_shape(inOption.rank, inOption.shape);
  
  is_attribute = inOption.is_attribute;

  return *this;
}

void OptionManager::Option::load_options(const string& filename){
  if(verbose)
    cout << "void OptionManager::Option::load_options(const string& filename = " << filename << ")\n";

  TiXmlDocument doc(filename);
  doc.SetCondenseWhiteSpace(false);
  if(!doc.LoadFile()){
    cerr << "WARNING: Failed to load options file.\n";
    return;
  }
  
  TiXmlNode *header = doc.FirstChild();
  TiXmlNode *fluidity_options = header->NextSibling();

  // Set the name of this element
  node_name = fluidity_options->ValueStr();

  // Decend down through all the fluidity options
  TiXmlNode *option_node=0;
  
  for(option_node=fluidity_options->FirstChild(); option_node; option_node=option_node->NextSibling()){
    if(option_node->ToElement()){
      parse_node("", option_node);
    }
  }

  return;
}

void OptionManager::Option::write_options(const string& filename) const{
  if(verbose)
    cout << "void OptionManager::Option::write_options(const string& filename = " << filename << ") const\n";
    
  TiXmlDocument doc;
  
  // XML header
  TiXmlDeclaration* header = new TiXmlDeclaration("1.0", "", "");
  doc.LinkEndChild(header);

  // Root node
  TiXmlNode* root_node = to_element();
  doc.LinkEndChild(root_node);

  if(!doc.SaveFile(filename)){
    cerr << "WARNING: Failed to write options file.\n";
  }

  return;
}

string OptionManager::Option::get_name() const{
  if(verbose)
    cout << "void OptionManager::Option::get_name(void) const\n";
  return node_name;
}

logical_t OptionManager::Option::get_is_attribute() const{
  if(verbose)
    cout << "void OptionManager::Option::get_is_attribute(void) const\n";
  return is_attribute;
}

void OptionManager::Option::list_children(const string& name, deque<string>& kids) const{
  if(verbose)
    cout << "void list_children(const string& name, deque<string>& kids) const\n";
  
  kids.clear();

  const OptionManager::Option* descendant = get_child(name);
  if(descendant != NULL){
    for(map<string, OptionManager::Option>::const_iterator it = descendant->children.begin();it != descendant->children.end();it++){
      kids.push_back(it->first);
    }
  }
  
  return;
}

const OptionManager::Option* OptionManager::Option::get_child(const string& key) const{
  if(verbose)
    cout << "const OptionManager::Option* OptionManager::Option::get_child((const string& key = " << key << ") const\n";

  if(key == "/" or key.empty())
    return this;

  string name, branch;
  int index;
  split_name(key, name, index, branch);

  if(name.empty()){
    cerr << "ERROR: child name cannot be empty\n";
    exit(-1);
  }

  multimap<string, OptionManager::Option>::const_iterator it;
  if(children.count(name) == 0){
    name += "::";
    int i = 0;
    for(it = children.begin();it != children.end();it++){
      if(it->first.compare(0, name.size(), name) == 0){
        if(index < 0 or i == index){
          break;
        }else{
          i++;
        }
      }
    }
  }else{
    if(index < 0){
      it = children.find(name);
    }else{
      pair<multimap< string, OptionManager::Option>::const_iterator, multimap<string, OptionManager::Option>::const_iterator> range = children.equal_range(name);
      it = range.first;
      for(size_t i = 0;it != range.second;it++, i++){
        if((int)i == index){
          break;
        }
      }
    }
  }

  if(it == children.end()){
    return NULL;
  }else if(branch.empty()){    
    return &(it->second);
  }else{
    return it->second.get_child(branch);
  }
}

OptionManager::Option* OptionManager::Option::get_child(const string& key){
  if(verbose)
    cout << "OptionManager::Option* OptionManager::Option::get_child(const string& key = " << key <<")\n";
    
  if(!have_option(key)){
    return NULL;
  }else{
    return create_child(key);
  }
}

/** 
 * Get the double data from the supplied key.
 */
int OptionManager::Option::get_option(string str, vector<double>& data) const{
  const OptionManager::Option* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/** 
 * Get the integer data from the supplied key.
 */
int OptionManager::Option::get_option(string str, vector<int>& data) const{
  const OptionManager::Option* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/**
 * Get the string data from the supplied key.
 */
int OptionManager::Option::get_option(string str, string& data) const{
  const OptionManager::Option* child = get_child(str);
  if(child == NULL){
    return -1;
  }else{
    return child->get_option(data);
  }
}

/** 
 * Get the number of elements at the supplied key. Searches un-named elements first, and if this is zero searches (from this highest element in the tree first) named elements.
 */
int OptionManager::Option::get_option_count(string str) const{
  if(verbose)
    cout<<"int OptionManager::Option::get_option_count("<<str<<") const\n";
  
  string name, branch;
  int index;
  split_name(str, name, index, branch);

  if(name.empty()){
    return 0;
  }
  
  if(!children.count(name)){
    // Apparently there is no such child but lets check for "name::*"
    name = name+"::";
  }

  int count=0, i=0;
  for(multimap<string, OptionManager::Option>::const_iterator it=children.begin();it!=children.end(); it++){
    if(it->first.compare(0, name.size(), name)==0){
      if(index<0){
        if(branch.empty())
          count++;
        else{
          count+=it->second.get_option_count(branch);
        }
      }else{
        if(i==index){
          if(branch.empty())
            count++;
          else
            count+=it->second.get_option_count(branch);
          break;
        }
        i++;
      }
    }
  }
  
  return count;
}

/** 
 * Get the double data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int OptionManager::Option::get_option(vector<double>& data) const{
  if(verbose)
    cout<<"const void* OptionManager::Option::get_option(vector<double>&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == SPUD_DOUBLE){
    data = data_double;
    return 0;
  }

  return -1;
}

/** 
 * Get the integer data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int OptionManager::Option::get_option(vector<int>& data) const{
  if(verbose)
    cout<<"const void* OptionManager::Option::get_option(vector<int>&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == SPUD_INT){
    data = data_int;
    return 0;
  }

  return -1;  
}

/** 
 * Get the string data from this element. Tranparently seeks into __value sub-element if this exists.
 */
int OptionManager::Option::get_option(string& data) const{
  if(verbose)
    cout<<"const void* OptionManager::Option::get_option(string&) const\n";

  if(have_option("__value")){
    return get_option("__value", data);
  }else if(get_option_type() == SPUD_STRING){
    data = data_string;
    return 0;
  }

  return -1;
}

/**
 * Get the rank of the data in this element.
 */
size_t OptionManager::Option::get_option_rank() const{
  if(have_option("__value")){
    return children.find("__value")->second.get_option_rank();
  }else{
    return rank;
  }
}

/**
 * Get the shape of the data in this element.
 */
void OptionManager::Option::get_option_shape(int *shape) const{
  if(have_option("__value")){
    children.find("__value")->second.get_option_shape(shape);
    return;
  }else{  
    shape[0] = this->shape[0];
    shape[1] = this->shape[1];
  }
}

/**
 * Get the type of the data in this element.
 */
OptionType OptionManager::Option::get_option_type() const{
  if(verbose)
    cout<<"OptionType OptionManager::Option::get_option_type() const\n";

  if(have_option("__value")){
    return children.find("__value")->second.get_option_type();
  }

  if(!data_double.empty()){
    return SPUD_DOUBLE;
  }else if(!data_int.empty()){
    return SPUD_INT;
  }else if(!data_string.empty()){
    return SPUD_STRING;
  }else{
    return SPUD_NONE;
  }
}

/**
 * Test if an element exists at the supplied key.
 */
logical_t OptionManager::Option::have_option(string str) const{
  if(verbose)
    cout<<"bool OptionManager::Option::have_option(\""<<str<<"\") const\n";

  if(str=="/")
    return true;

  return (get_child(str) != NULL);
}

/**  Print this element to standard output.
  */
void OptionManager::Option::print(const string& prefix) const{
  cout<<prefix<<node_name;
  string lprefix = prefix + " ";
  
  if(children.empty()){
    cout<<": ";
    if(!data_double.empty())
      for(vector<double>::const_iterator i=data_double.begin();i!=data_double.end();++i)
        cout<<*i<<" ";
    else if(!data_int.empty())
      for(vector<int>::const_iterator i=data_int.begin();i!=data_int.end();++i)
        cout<<*i<<" ";
    else if(!data_string.empty())
      cout<<data_string;
    else
      cout<<"NULL";
    cout<<endl;
  }else{
    cout<<"/"<<endl;
    
    if(!data_double.empty()){
      cout<<lprefix<<"<value>: ";
      for(vector<double>::const_iterator i=data_double.begin();i!=data_double.end();++i)
        cout<<*i<<" ";
      cout<<endl;
    }else if(!data_int.empty()){
      cout<<lprefix<<"<value>: ";
      for(vector<int>::const_iterator i=data_int.begin();i!=data_int.end();++i)
        cout<<*i<<" ";
      cout<<endl;
    }else if(!data_string.empty()){
      cout<<lprefix<<"<value>: "<<data_string;
      cout<<endl;
    }
    for(map<string, OptionManager::Option>::const_iterator i=children.begin(); i!=children.end(); ++i)
      i->second.print(lprefix + " ");
  }
  return;
}

/**  Find or add a new element at the supplied key.
  */
int OptionManager::Option::add_option(string str){
  return create_child(str) == NULL ? 1 : 0;
}

/**  Set the data in the element with the supplied double data. Transparently sets the data of a __value sub-element if this exists.
  */
int OptionManager::Option::set_option(int rank, const int *shape, vector<double>& data){
  if(have_option("__value")){
    return set_option("__value", rank, shape, data);
  }else{  
    data_double = data;
    set_option_type(SPUD_DOUBLE);
    set_rank_and_shape(rank, shape);
    return 0;
  }
}

/**  Set the data at the supplied key with the supplied double data.
  */
int OptionManager::Option::set_option(string str, int rank, const int *shape, vector<double>& data){
  OptionManager::Option* opt = create_child(str);
    
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(rank, shape, data);
  }
}

/**  Set the data in the element with the supplied integer data. Transparently sets the data of a __value sub-element if this exists.
  */
int OptionManager::Option::set_option(int rank, const int *shape, vector<int>& data){
  if(have_option("__value")){
    return set_option("__value", rank, shape, data);
  }else{  
    data_int = data;
    set_option_type(SPUD_INT);
    set_rank_and_shape(rank, shape);
    return 0;
  }
}

/**  Set the data at the supplied key with the supplied integer data.
  */
int OptionManager::Option::set_option(string str, int rank, const int *shape, vector<int>& data){
  OptionManager::Option* opt = create_child(str);
  
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(rank, shape, data);
  }
}

/**  Set the data in the element with the supplied string data. Transparently sets the data of a __value sub-element if this exists.
  */
int OptionManager::Option::set_option(string data){
  if(verbose)
    cout<<"void OptionManager::Option::set_option("<<data<<")\n";

  if(have_option("__value")){
    return set_option("__value", data);
  }else{
    data_string = data;
    int rank = data.size();
    set_option_type(SPUD_STRING);
    set_rank_and_shape(1, &rank);
    return 0;
  };
}

/**  Set the data at the supplied key with the supplied string data.
  */
int OptionManager::Option::set_option(string str, string data){
  if(verbose)
    cout<<"void OptionManager::Option::set_option("<<str<<", "<<data<<")\n";

  OptionManager::Option* opt = create_child(str);
    
  if(opt == NULL){
    return -1;
  }else{
    return opt->set_option(data);
  }
}

/**  Set the data of this element with the supplied string data, and mark this element as an attribute.
  */
int OptionManager::Option::set_attribute(string str, string data){
  if(verbose)
    cout << "logical_t OptionManager::Option::set_attribute(" << str << ", " << data << ")\n";
  
  OptionManager::Option* opt = create_child(str);
  
  if(opt == NULL){
    return -1;
  }else{
    int ret = opt->set_option(data);
    opt->set_is_attribute(true);
    return ret;
  }
}

logical_t OptionManager::Option::set_is_attribute(const logical_t& is_attribute){
  if(verbose)
    cout << "void OptionManager::Option::set_is_attribute(const logical_t& is_attribute = " << is_attribute << ")\n";
  if(children.size() == 0 and get_option_type() == SPUD_STRING){
    this->is_attribute = is_attribute;
  }
  
  return this->is_attribute;
}

/**  Delete the element at the supplied key.
  */
int OptionManager::Option::delete_option(string str){
  if(verbose)
    cout << "void OptionManager::Option::delete_option(" << str << ")\n";

  string branch, name;
  split_name(str, name, branch);
 
  OptionManager::Option* opt = get_child(name);
  
  if(opt == NULL){
    return -1;
  }else if(branch.empty()){
    for(multimap<string, OptionManager::Option>::iterator it = children.begin();it != children.end();it++){
      if(&it->second == opt){
        children.erase(it);
        return 0;
      }
    }
    return -1;
  }else{
    return opt->delete_option(branch);
  }
}

/**  Turn on verbosity for this element (used for debugging only).
  */
void OptionManager::Option::verbose_on(){
  verbose = true;
}

/**  Turn off verbosity for this element.
  */
void OptionManager::Option::verbose_off(){
  verbose = false;
}

// PRIVATE METHODS

void OptionManager::Option::tokenize(const string& str,
                                     vector<string>& tokens,
                                     const string& delimiters) const{
  tokens.clear();
  
  // Skip delimiters at beginning.
  string::size_type lastPos = str.find_first_not_of(delimiters, 0);
  
  // Find first "non-delimiter".
  string::size_type pos     = str.find_first_of(delimiters, lastPos);
  
  while (string::npos != pos || string::npos != lastPos){
    // Found a token, add it to the vector.
    tokens.push_back(str.substr(lastPos, pos - lastPos));
    
    // Skip delimiters.  Note the "not_of"
    lastPos = str.find_first_not_of(delimiters, pos);
    
    // Find next "non-delimiter"
    pos = str.find_first_of(delimiters, lastPos);
  }
  
  return;
}

/**  Split the supplied key in into the highest child name (including its index) and key from that sub -child.
  */
int OptionManager::Option::split_name(const string in, string& name, string& branch) const{
  if(verbose){
    cout << "int OptionManager::Option::split_name(" << in << ", " << name << ", " << branch << ")\n";
  }

  string valid_chars("/_:[]1234567890qwertyuioplkjhgfdsazxcvbnmMNBVCXZASDFGHJKLPOIUYTREWQ");
  string fullname = in.substr(0, min(in.size(), in.find_first_not_of(valid_chars)));
 
  // Skip delimiters at beginning.
  string::size_type lastPos = fullname.find_first_not_of("/", 0);
  if(lastPos==string::npos)
    return 0;
  
  // Find next delimiter
  string::size_type pos = fullname.find_first_of("/", lastPos);
  
  if(pos==string::npos){
    name = fullname.substr(lastPos, fullname.size() - lastPos);
  }else{
    name = fullname.substr(lastPos, pos - lastPos);
    branch = fullname.substr(pos, fullname.size()-pos);
  }

  return 0;  
}

/**  Split the supplied key in into the highest child name (excluding its index), the index of that sub-child, and the key from that sub-child.
  */
int OptionManager::Option::split_name(const string in, string& name, int &index, string& branch) const{
  if(verbose)
    cout<<"int OptionManager::Option::split_name("<<in<<", string& name , string& branch)\n";
  
  int ret = split_name(in, name, branch);
  if(ret != 0){
    return ret;
  }    
  
  // Extract the index from the name if necessary
  string::size_type pos = name.find_first_of("[", 0);
  string::size_type lastPos = name.find_first_of("]", 0);
  index = -1;
  if((lastPos-pos)>0){
    istringstream(name.substr(pos+1, lastPos-1))>>index;
    name = name.substr(0, pos);
  }
  
  return 0;
}

/**  Split a node name into the child name (excluding the name attribute) and it's name attribute (which may be empty).
  */
void OptionManager::Option::split_node_name(string& node_name, string& name_attr) const{
  if(verbose){
    cout << "void OptionManager::Option::split_node_name(" << node_name << ", " << name_attr << "&) const\n";
  }
  
  string::size_type firstPos = this->node_name.rfind("::");
  if(firstPos == string::npos or firstPos == this->node_name.size() - 2){
    node_name = this->node_name;
    name_attr = "";
  }
  else{
    node_name = this->node_name.substr(0, firstPos);
    name_attr = this->node_name.substr(firstPos + 2);
  }
  
  return;
}

/**  Converts the data for this element into a string.
  */
string OptionManager::Option::data_as_string() const{
  if(verbose){
    cout << "string OptionManager::Option::data_as_string(void) const\n";
  }

  stringstream data_as_string; 
  switch(get_option_type()){
    case(SPUD_DOUBLE):
      for(unsigned int i = 0;i < data_double.size();i++){
        data_as_string << data_double[i];
        if(i < data_double.size() - 1){
          data_as_string << " ";
        }
      }
      return data_as_string.str();
    case(SPUD_INT):
      for(unsigned int i = 0;i < data_int.size();i++){
        data_as_string << data_int[i];
        if(i < data_int.size() - 1){
          data_as_string << " ";
        }
      }
      return data_as_string.str();
    case(SPUD_NONE):
      return "";
    case(SPUD_STRING):
      return data_string;
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
}

/**  Finds or creates a new child at the supplied key, and returns that child. If the parent of a created child is marked as an attribute, unmarks it.
  */
OptionManager::Option* OptionManager::Option::create_child(string str){
  if(verbose)
    cout<<"OptionManager::Option& OptionManager::Option::create_child("<<str<<")\n";

  if(str == "/" or str.empty())
    return this;
  
  string branch, name;
  int index;
  split_name(str, name, index, branch);

  if(name.empty()){
    cerr << "ERROR: child name cannot be empty\n";
    exit(-1);
  }

  multimap<string, OptionManager::Option>::iterator child;
  if(children.count(name) == 0){
    string name2 = name + "::";
    int i = 0;
    for(child = children.begin();child != children.end();child++){
      if(child->first.compare(0, name2.size(), name2) == 0){
        if(index < 0 or i == index){
          break;
        }else{
          i++;
        }
      }
    }
    if(child == children.end()){
      if(name == "__value" and get_option_type() != SPUD_NONE){
        cerr << "WARNING: Creating __value child for non null element - deleting parent data\n";
        set_option_type(SPUD_NONE);
      }
      child = children.insert(pair<string, OptionManager::Option>(name, OptionManager::Option(name)));
      string new_node_name, name_attr;
      child->second.split_node_name(new_node_name, name_attr);
      if(name_attr.size() > 0){
        child->second.set_attribute("name", name_attr);
      }
      is_attribute = false;
    }
  }else{
    if(index < 0){
      child = children.find(name);
    }else{
      pair<multimap< string, OptionManager::Option>::iterator, multimap<string, OptionManager::Option>::iterator> range = children.equal_range(name);
      child = range.first;
      for(size_t i = 0;child != range.second;child++, i++){
        if((int)i == index){
          break;
        }
      }
    }
  }

  if(child == children.end()){
    return NULL;
  }else if(branch.empty()){
    return &child->second;
  }else{
    return child->second.create_child(branch);
  }
}

/**  Set the rank and shape for the data in this element.
  */
void OptionManager::Option::set_rank_and_shape(int rank, const int* shape){
  logical_t set_attrs = false;
  if(rank > 0){
    OptionType option_type = get_option_type();
    set_attrs = (option_type == SPUD_DOUBLE or option_type == SPUD_INT);
  }
  switch(rank){
    case(-1):
      this->rank = -1;
      this->shape[0] = -1;
      this->shape[1] = -1;
      break;
    case(0):
      this->rank = 0;
      this->shape[0] = -1;
      this->shape[1] = -1;
      break;
    case(1):
      this->rank = 1;
      this->shape[0] = shape[0];
      this->shape[1] = -1;
      if(set_attrs){
        stringstream rank_as_string;
        rank_as_string << this->rank;
        set_attribute("rank", rank_as_string.str());
        stringstream shape_as_string;
        shape_as_string << shape[0];
        set_attribute("shape", shape_as_string.str());
      }
      break;
    case(2):
      this->rank = 2;
      this->shape[0] = shape[0];
      this->shape[1] = shape[1];
      if(set_attrs){
        stringstream rank_as_string;
        rank_as_string << this->rank;
        set_attribute("rank", rank_as_string.str());
        stringstream shape_as_string;
        shape_as_string << shape[0] << " " << shape[1];
        set_attribute("shape", shape_as_string.str());
      }
      break;
    default:
      cerr << "ERROR: Invalid option rank\n";
      exit(-1);
  }

  return;
}

/**  Set the option type for this element, and delete all data of other option types. If the new option type is not string type and this element is marked as an attribute, unmarks it.
  */
void OptionManager::Option::set_option_type(OptionType option_type){
  switch(option_type){
    case(SPUD_DOUBLE):
      data_int.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(SPUD_INT):
      data_double.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(SPUD_NONE):
      data_double.clear();
      data_int.clear();
      data_string = "";
      is_attribute = false;
      break;
    case(SPUD_STRING):
      data_double.clear();
      data_int.clear();
      break;
    default:
      cerr << "ERROR: Invalid option type\n";
      exit(-1);
  }
  
  return;
}

/**  Parses the supplied TiXmlNode and sets the data and and attribute status of this element appropriately.
  */
void OptionManager::Option::parse_node(string root, const TiXmlNode *node){
  if(verbose)
    cout<<"void OptionManager::Option::parse_option(\""<<root<<"\", const TiXmlNode *node)\n"; 
  
  // In fact I think at this level I only ever deal with ELEMENT -
  // time will tell
  if(node->Type()!=TiXmlNode::ELEMENT){
    cerr<<"WARNING - non-element: "<<root<<endl;
    return;
  }

  const TiXmlElement *element = node->ToElement();
  
  // Establish new base name of this node
  string basename = root+"/"+node->ValueStr();
  if(element->Attribute("name")){
    basename = basename+"::"+element->Attribute("name");
  }

  // Ensure this path has been added
  OptionManager::Option* child = create_child(basename);
  if(child == NULL){
    cerr << "ERROR: Unexpected failure when creating child element\n";
    exit(-1);
  }

  // Store node attributes
  for(const TiXmlAttribute *att=element->FirstAttribute(); att; att=att->Next()){
    string att_name(basename+"/"+att->Name());
    set_attribute(att_name, att->ValueStr());
  }

  // Loop through all child elements
  for(const TiXmlNode *cnode=node->FirstChild(); cnode; cnode=cnode->NextSibling()){
    switch(cnode->Type()){
      case(TiXmlNode::ELEMENT):
        break;
      case(TiXmlNode::TEXT):
        // Store node data
        set_option(basename, cnode->ValueStr());
        continue;
      default:
        continue;
    }

    // Special case when the child of cnode is empty
    if(!cnode->FirstChild()){
      parse_node(basename, cnode);
      continue;
    }
    
    const TiXmlElement *celement = cnode->ToElement();      
        
    if(cnode->ValueStr()==string("integer_value")){
      // Tokenise the data stored and convert to integers
      vector<string> tokens;
      tokenize(cnode->FirstChild()->ValueStr(), tokens);
      
      // Find shape and rank
      int rank, shape[2];
      istringstream(celement->Attribute("rank"))>>rank;
      if(rank==1){
        // istringstream(celement->Attribute("shape"))>>shape[0];
        shape[0] = tokens.size();
      }else if(rank==2){
        istringstream(celement->Attribute("shape"))>>shape[0]>>shape[1];
      }
      
      vector<int> val;
      val.resize(tokens.size());
      for(size_t i=0;i<tokens.size();i++)
        istringstream(tokens[i])>>val[i];
      
      set_option(basename+"/__value", rank, shape, val);
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else if(cnode->ValueStr()==string("real_value")){
      // Tokenise the data stored and convert to integers
      vector<string> tokens;
      tokenize(cnode->FirstChild()->ValueStr(), tokens);
      
      // Find shape and rank
      int rank, shape[2];
      istringstream(celement->Attribute("rank"))>>rank;
      if(rank==1){
        shape[0] = tokens.size();
      }else if(rank==2){
        istringstream(celement->Attribute("shape"))>>shape[0]>>shape[1];
      }
            
      vector<double> val;
      val.resize(tokens.size());
      for(size_t i=0;i<tokens.size();i++)
        istringstream(tokens[i])>>val[i];
            
      set_option(basename+"/__value", rank, shape, val);
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else if(cnode->ValueStr()==string("string_value")){
      set_option(basename+"/__value", cnode->FirstChild()->ValueStr());
      for(const TiXmlAttribute *att=celement->FirstAttribute(); att; att=att->Next()){
        string att_name(basename+"/__value/"+att->Name());
        set_attribute(att_name, att->ValueStr());
      }
    }else{
      parse_node(basename, cnode);
    }
  }
}

/**  Convert this element into a TiXmlElement.
  */
TiXmlElement* OptionManager::Option::to_element() const{
  if(verbose){
    cout << "TiXmlElement* to_element(void) const\n";
  }

  // Create new element
  TiXmlElement* ele = new TiXmlElement(node_name);

  // Set element name and name attribute if composite name
  string node_name, name_attr;
  split_node_name(node_name, name_attr);
  if(name_attr.size() > 0){
    ele->SetValue(node_name);
    ele->SetAttribute("name", name_attr);
  }
  
  // Set data
  TiXmlText* data_ele = new TiXmlText("");
  data_ele->SetValue(data_as_string());
  ele->LinkEndChild(data_ele);
  
  for(map<string, OptionManager::Option>::const_iterator iter = children.begin();iter != children.end();iter++){
    if(iter->second.is_attribute){
      // Add attribute
      ele->SetAttribute(iter->second.node_name, iter->second.data_as_string());
    }else{
      TiXmlElement* child_ele = iter->second.to_element();
      if(iter->second.node_name == "__value"){
        // Detect data sub-element
        switch(iter->second.get_option_type()){
          case(SPUD_DOUBLE):
            child_ele->SetValue("real_value");
            break;
          case(SPUD_INT):
            child_ele->SetValue("integer_value");
            break;
          case(SPUD_NONE):
            break;
          case(SPUD_STRING):
            child_ele->SetValue("string_value");
            break;
          default:
            cerr << "ERROR: Invalid option type\n";
            exit(-1);
         }
      }
      // Add child
      ele->LinkEndChild(child_ele);
    }
  }
  return ele;
}

// END OF OptionManager::Option CLASS METHODS
