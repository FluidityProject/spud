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

// VERY TEMPORARY
#if 0


// FORTRAN INTERFACES

extern "C" {
#define chave_option_fc F77_FUNC(chave_option, CHAVE_OPTION)
  int chave_option_fc(const char *str, const int *len){
    if(fluidity_options->have_option(string(str, *len))){
      return 1;
    }else{
      return 0;
    }
  }
  
#define cget_child_name_fc F77_FUNC(cget_child_name, CGET_CHILD_NAME)
  int cget_child_name_fc(const char *str, const int *len, const int *index, char *child_name){
   string name(str, *len);

   if(!fluidity_options->have_option(name))
      return -1;
    
    deque<string> kids;
    fluidity_options->list_children(name, kids);
    
    if(kids.size()<=(size_t)(*index)){
      return -1;
    }

    //strncpy(child_name, kids[*index].c_str(), 8192);
    memcpy(child_name, kids[*index].c_str(), kids[*index].size());
    
    return 0;
  }

#define cget_number_of_children_fc F77_FUNC(cget_number_of_children, CGET_NUMBER_OF_CHILDREN)
  int cget_number_of_children_fc(const char *str, const int *len, int *count){
    *count = 0;
    
    string name(str, *len);

    if(!fluidity_options->have_option(name))
      return -1;

    deque<string> kids;
    fluidity_options->list_children(name, kids);
    
    *count = kids.size();

    return 0;
  }
  
#define cget_option_count_fc F77_FUNC(cget_option_count, CGET_OPTION_COUNT)
  int cget_option_count_fc(const char *str, const int *len, int *count){
    *count = fluidity_options->get_option_count(string(str, *len));
    return 0;
  }

#define cget_option_info_fc F77_FUNC(cget_option_info, CGET_OPTION_INFO)
  int cget_option_info_fc(const char *str, const int *len, int *shape, int *rank, int *type){
    string name(str, *len);

    const OptionManager::Option* option = fluidity_options->get_child(name);
    if(option == NULL){
      return -1;
    }

    option->get_option_shape(shape);
    *rank = option->get_option_rank();
    *type = option->get_option_type();
    
    return 0;
  }

#define cget_option_fc F77_FUNC(cget_option, CGET_OPTION)
  int cget_option_fc(const char *str, const int *len, void *val){
    string name(str, *len);
  
    const OptionManager::Option* option = fluidity_options->get_child(name);
    
    if(option == NULL){
      return -1;
    }

    if(option->get_option_type()==OPTION_TYPE_BOOL){
      // memcpy(val, option->get_option(), option->get_option_size()*sizeof(double));
      cerr<<"cget_option_fc still broken for logicals\n";
      return -1;
    }else if(option->get_option_type()==SPUD_DOUBLE){
      vector<double> data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      for(size_t i=0;i<data.size();i++)
        ((double *)val)[i] = data[i];
    }else if(option->get_option_type()==SPUD_INT){
      vector<int> data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      for(size_t i=0;i<data.size();i++)
        ((int *)val)[i] = data[i];
    }else if(option->get_option_type()==SPUD_STRING){
      string data;
      int ret = option->get_option(data);
      if(ret != 0){
        return ret;
      }
      memcpy(val, data.c_str(), data.size()*sizeof(char));
    }else{
      return -1;
    }
    
    return 0;
  }
  
#define cadd_option_fc F77_FUNC(cadd_option, CADD_OPTION)
  int cadd_option_fc(const char* str, const int* str_len){
    return fluidity_options->add_option(string(str, *str_len));
  }

#define cset_option_fc F77_FUNC(cset_option, CSET_OPTION)
  int cset_option_fc(const char *str, const int *str_len, const int *shape, const int *rank, const int *type, void *data){
    string name(str, *str_len);
    
    // Get the size of the data
    size_t len = 1;
    if((*rank)>0)
      len = *shape;
    for(int i=1;i<(*rank);i++){
      len*=shape[i];
    }

    if(*type == SPUD_DOUBLE){
      vector<double> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((double *)data)[i];
      return fluidity_options->set_option(name, *rank, shape, option_data);
    }else if(*type == SPUD_INT){
      vector<int> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((int *)data)[i];
      return fluidity_options->set_option(name, *rank, shape, option_data);
    }else if(*type == SPUD_STRING){
      return fluidity_options->set_option(name, string((const char *)data, len));
    }else if(*type == OPTION_TYPE_BOOL){
      vector<logical_t> option_data(len);
      for(size_t i=0;i<len;i++)
        option_data[i] = ((logical_t *)data)[i];
      return fluidity_options->set_option(name, *rank, shape, option_data);
    }else{
      cerr << "ERROR: unsupported type passed into set_option(): " << __FILE__ << ", "<< __LINE__ <<endl;
      return -1;
    }
  }
  
#define cset_option_is_attribute_fc F77_FUNC(cset_option_is_attribute, CSET_OPTION_IS_ATTRIBUTE)
  int cset_option_is_attribute_fc(const char *str, const int *str_len, int* is_attribute_set, int* is_attribute_get = NULL){    
    string name(str, *str_len);
    
    OptionManager::Option* opt = fluidity_options->get_child(name);
    if(opt == NULL){
      return -1;
    }else{
      logical_t is_attribute = opt->set_is_attribute(*is_attribute_set);
      if(is_attribute_get != NULL){
        *is_attribute_get = is_attribute ? 1 : 0;
      }
      return 0;
    }
  }
  
#define cdelete_option_fc F77_FUNC(cdelete_option, CDELETE_OPTION)
  int cdelete_option_fc(const char* str, const int* len){
    return fluidity_options->delete_option(string(str, *len));
  }
  
#define cload_option_fc F77_FUNC(cload_option, CLOAD_OPTION)
  void cload_option_fc(char* str, const int* len)
  {
    fluidity_options->load_options_xml(string(str, *len));

    return;
  }

#define cwrite_option_fc F77_FUNC(cwrite_option, CWRITE_OPTION)
  void cwrite_option_fc(char* str, const int* len)
  {
    fluidity_options->write_options_xml(string(str, *len));

    return;
  }
}

#endif
