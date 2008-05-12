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

#ifndef CSPUD_H
#define CSPUD_H

//#include "confdefs.h"

#ifndef F77_FUNC
#define F77_FUNC(name, NAME) name ## _
#endif

#define spud_load_options F77_FUNC(spud_load_options, SPUD_LOAD_OPTIONS)
#define spud_write_options F77_FUNC(spud_write_options, SPUD_WRITE_OPTIONS)
#define spud_get_child_name F77_FUNC(spud_get_child_name, SPUD_GET_CHILD_NAME)
#define spud_get_number_of_children F77_FUNC(spud_get_number_of_children, SPUD_GET_NUMBER_OF_CHILDREN)
#define spud_option_count F77_FUNC(spud_option_count, SPUD_OPTION_COUNT)
#define spud_have_option F77_FUNC(spud_have_option, SPUD_HAVE_OPTION)
#define spud_get_option_type F77_FUNC(spud_get_option_type, SPUD_GET_OPTION_TYPE)
#define spud_get_option_rank F77_FUNC(spud_get_option_rank, SPUD_GET_OPTION_RANK)
#define spud_get_option_shape F77_FUNC(spud_get_option_shape, SPUD_GET_OPTION_SHAPE)
#define spud_get_option F77_FUNC(spud_get_option, SPUD_GET_OPTION)
#define spud_add_option F77_FUNC(spud_add_option, SPUD_ADD_OPTION)
#define spud_set_option F77_FUNC(spud_set_option, SPUD_SET_OPTION)
#define spud_set_option_attribute F77_FUNC(spud_set_option_attribute, SPUD_SET_OPTION_ATTRIBUTE)
#define spud_delete_option F77_FUNC(spud_delete_option, SPUD_DELETE_OPTION)

#ifdef __cplusplus
extern "C" {
#endif
  void spud_load_options(const char* key, const int* key_len);
  void spud_write_options(const char* key, const int* key_len);
  
  int spud_get_child_name(const char* key, const int* key_len, const int* index, char* child_name, const int* child_name_len);
  
  int spud_number_of_children(const char* key, const int* key_len);
  
  int spud_option_count(const char* key, const int* key_len);
  
  int spud_have_option(const char* key, const int* key_len);
  
  int spud_get_option_type(const char* key, const int* key_len, int* type);
  int spud_get_option_rank(const char* key, const int* key_len, int* rank);
  int spud_get_option_shape(const char* key, const int* key_len, int* shape);
  
  int spud_get_option(const char* key, const int* key_len, void* val);
  
  int spud_add_option(const char* key, const int* key_len);
  
  int spud_set_option(const char* key, const int* key_len, const void* val, const int* type, const int* rank, const int* shape);

  int spud_set_option_attribute(const char* key, const int* key_len, const char* val, const int* val_len);
  
  int spud_delete_option(const char* key, const int* key_len);
#ifdef __cplusplus
}
#endif

#endif
