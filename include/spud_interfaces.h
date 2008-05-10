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

// If the following two lines have been committed, please delete them!
#define F77_FUNC(name,NAME) name ## _
#define F77_FUNC_(name,NAME) name ## _

extern "C" {
#define cload_options F77_FUNC(cload_options, CLOAD_OPTIONS)
  void cload_options(const char* key, const int* ley_len);
#define cwrite_options F77_FUNC(cwrite_options, CWRITE_OPTIONS)
  void cwrite_options(const char* key, const int* key_len);
  
#define cget_child_name F77_FUNC(cget_child_name, CGET_CHILD_NAME)
  int cget_child_name(const char* key, const int* key_len, const int* index, char* child_name, const int* child_name_len);
  
#define cget_number_of_children F77_FUNC(cget_number_of_children, CGET_NUMBER_OF_CHILDREN)
  int cnumber_of_children(const char* key, const int* key_len);
  
#define coption_count F77_FUNC(coption_count, COPTION_COUNT)
  int coption_count(const char* key, const int* key_len);
  
#define chave_option F77_FUNC(chave_option, CHAVE_OPTION)
  int chave_option(const char* key, const int* key_len);
  
#define cget_option_type F77_FUNC(cget_option_type, GET_OPTION_TYPE)
  int cget_option_type(const char* key, const int* key_len, int* type);
#define cget_option_rank F77_FUNC(cget_option_rank, CGET_OPTION_RANK)
  int cget_option_rank(const char* key, const int* key_len, int* rank);
#define cget_option_shape F77_FUNC(cget_option_shape, CGET_OPTION_SHAPE)
  int cget_option_shape(const char* key, const int* key_len, int* shape);
  
#define cget_option F77_FUNC(cget_option, CGET_OPTION)
  int cget_option(const char* key, const int* key_len, void* option);
  
#define cadd_option F77_FUNC(cadd_option, CADD_OPTION)
  int cadd_option(const char* key, const int* key_len);

#define cset_option_attribute F77_FUNC(cset_option_attribute, CSET_OPTION_ATTRIBUTE)
  int cset_option_attribute(const char* key, const int* key_len, const char* option, const int* option_len);
  
#define cset_option F77_FUNC(cset_option, CSET_OPTION)
  int cset_option(const char* key, const int* key_len, const void* option, const int* type, const int* rank, const int* shape);
  
#define cdelete_option F77_FUNC(cdelete_option, CDELETE_OPTION)
  int cdelete_option(const char* key, const int* key_len);
}
