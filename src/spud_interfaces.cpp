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

#include "spud_interfaces.h"

#ifndef SPUD_INTERFACES_H
#define SPUD_INTERFACES_H

using namespace std;

using namespace Spud;

extern "C" {
  void cload_options(const char* key, const int* key_len)
  {
    OptionManager::load_options(string(key, *key_len));

    return;
  }
  
  void cwrite_options(const char* key, const int* key_len)
  {
    OptionManager::write_options(string(key, *key_len));

    return;
  }
  
  int cget_child_name(const char* key, const int* key_len, const int* index, char* child_name, const int* child_name_len){
    string child_name_handle;
    OptionError get_name_err = OptionManager::get_child_name(string(key, *key_len), *index, child_name_handle);
    if(get_name_err != SPUD_NO_ERROR){
      return get_name_err;
    }
    
    int copy_len = (int)child_name_handle.size() > *child_name_len ? *child_name_len : child_name_handle.size();
    memcpy(child_name, child_name_handle.c_str(), copy_len);
    
    return SPUD_NO_ERROR;
  }

  int cnumber_of_children(const char* key, const int* key_len){
    return OptionManager::number_of_children(string(key, *key_len));
  }
  
  int coption_count(const char* key, const int* key_len){
    return OptionManager::option_count(string(key, *key_len));
  }
  
  int chave_option(const char* key, const int* key_len){
    return OptionManager::have_option(string(key, *key_len)) ? 1 : 0;
  }
  
  int cget_option_type(const char* key, const int* key_len, int* type){
    OptionType type_handle;
    OptionError get_type_err = OptionManager::get_option_type(string(key, *key_len), type_handle);
    if(get_type_err != SPUD_NO_ERROR){
      return get_type_err;
    }
    
    *type = type_handle;
    
    return SPUD_NO_ERROR;
  }

  int cget_option_rank(const char* key, const int* key_len, int* rank){
    return OptionManager::get_option_rank(string(key, *key_len), *rank);
  }
  
  int cget_option_shape(const char* key, const int* key_len, int* shape){
    vector<int> shape_handle;
    OptionError get_shape_err = OptionManager::get_option_shape(string(key, *key_len), shape_handle);
    if(get_shape_err != SPUD_NO_ERROR){
      return get_shape_err;
    }
    
    shape[0] = shape_handle[0];  shape[1] = shape_handle[1];
    
    return SPUD_NO_ERROR;
  }
  
  int cget_option(const char* key, const int* key_len, void* option){
    string key_handle(key, *key_len);
  
    OptionType type;
    OptionError get_type_err = OptionManager::get_option_type(key_handle, type);
    if(get_type_err != SPUD_NO_ERROR){
      return get_type_err;
    }
    
    int rank;
    OptionError get_rank_err = OptionManager::get_option_rank(key_handle, rank);
    if(get_rank_err != SPUD_NO_ERROR){
      return get_rank_err;
    }

    if(type == SPUD_DOUBLE){
      if(rank == 0){
        double option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        *((double*)option) = option_handle;
      }else if(rank == 1){
        vector<double> option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        for(size_t i = 0;i < option_handle.size();i++){
          ((double*)option)[i] = option_handle[i];
        }
      }else if(rank == 2){
        vector< vector<double> > option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        for(size_t i = 0;i < option_handle.size();i++){
          for(size_t j = 0;j < option_handle[0].size();j++){
            ((double*)option)[i * option_handle[0].size() + j] = option_handle[i][j];
          }
        }
      }else{
        cerr << "ERROR: Invalid option rank\n";
        exit(-1);
      }
    }else if(type == SPUD_INT){
      if(rank == 0){
        int option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        *((int*)option) = option_handle;
      }else if(rank == 1){
        vector<int> option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        for(size_t i = 0;i < option_handle.size();i++){
          ((int*)option)[i] = option_handle[i];
        }
      }else if(rank == 2){
        vector< vector<int> > option_handle;
        OptionError get_err = OptionManager::get_option(key_handle, option_handle);
        if(get_err != SPUD_NO_ERROR){
          return get_err;
        }
        for(size_t i = 0;i < option_handle.size();i++){
          for(size_t j = 0;j < option_handle[0].size();j++){
            ((int*)option)[i * option_handle[0].size() + j] = option_handle[i][j];
          }
        }
      }else{
        cerr << "ERROR: Invalid option rank\n";
        exit(-1);
      }
    }else if(type == SPUD_STRING){
      string option_handle;
      OptionError get_err = OptionManager::get_option(key_handle, option_handle);
      if(get_err != SPUD_NO_ERROR){
        return get_err;
      }
      memcpy(option, option_handle.c_str(), option_handle.size() * sizeof(char));
    }else{
      return SPUD_TYPE_ERROR;
    }
    
    return SPUD_NO_ERROR;
  }
  
  int cadd_option(const char* key, const int* key_len){
    return OptionManager::add_option(string(key, *key_len));
  }
  
  int cset_option(const char* key, const int* key_len, const void* option, const int* type, const int* rank, const int* shape){
    string key_handle(key, *key_len);

    if(*type == SPUD_DOUBLE){
      if(*rank == 0){
        double option_handle = *((double*)option);
        return OptionManager::set_option(key_handle, option_handle);
      }else if(*rank == 1){
        vector<double> option_handle;
        for(int i = 0;i < shape[0];i++){
          option_handle.push_back(((double*)option)[i]);
        }
        return OptionManager::set_option(key_handle, option_handle);
      }else if(*rank == 2){
        vector< vector<double> > option_handle;
        for(int i = 0;i < shape[0];i++){
          option_handle.push_back(vector<double>());
          for(int j = 0;j < shape[1];j++){
            option_handle[i].push_back(((double*)option)[i * option_handle[0].size() + j]);
          }
        }
        return OptionManager::set_option(key_handle, option_handle);    
      }else{
        cerr << "ERROR: Invalid option rank\n";
        exit(-1);
      }
    }else if(*type == SPUD_INT){
      if(*rank == 0){
        int option_handle = *((int*)option);
        return OptionManager::set_option(key_handle, option_handle);
      }else if(*rank == 1){
        vector<int> option_handle;
        for(int i = 0;i < shape[0];i++){
          option_handle.push_back(((int*)option)[i]);
        }
        return OptionManager::set_option(key_handle, option_handle);
      }else if(*rank == 2){
        vector< vector<int> > option_handle;
        for(int i = 0;i < shape[0];i++){
          option_handle.push_back(vector<int>());
          for(int j = 0;j < shape[1];j++){
            option_handle[i].push_back(((int*)option)[i * option_handle[0].size() + j]);
          }
        }
        return OptionManager::set_option(key_handle, option_handle);
      }else{
        cerr << "ERROR: Invalid option rank\n";
        exit(-1);
      }
    }else if(*type == SPUD_STRING){
      return OptionManager::set_option(key_handle, string((char*)option, shape[0]));
    }else{
      return SPUD_TYPE_ERROR;
    }
    
    return SPUD_NO_ERROR;
  }
   
  int cset_option_attribute(const char* key, const int* key_len, const char* option, const int* option_len){
    return OptionManager::set_option_attribute(string(key, *key_len), string(option, *option_len));
  }
   
  int cdelete_option(const char* key, const int* key_len){
    return OptionManager::delete_option(string(key, *key_len));
  }
}

#endif
