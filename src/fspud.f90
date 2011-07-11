!    Copyright (C) 2007 Imperial College London and others.
!
!    Please see the AUTHORS file in the main source directory for a full list
!    of copyright holders.
!
!    Applied Modelling and Computation Group
!    Department of Earth Science and Engineering
!    Imperial College London
!
!    David.Ham@Imperial.ac.uk
!
!    This library is free software; you can redistribute it and/or
!    modify it under the terms of the GNU Lesser General Public
!    License as published by the Free Software Foundation,
!    version 2.1 of the License.
!
!    This library is distributed in the hope that it will be useful,
!    but WITHOUT ANY WARRANTY; without even the implied warranty of
!    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
!    Lesser General Public License for more details.
!
!    You should have received a copy of the GNU Lesser General Public
!    License along with this library; if not, write to the Free Software
!    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
!    USA

module spud
  use iso_c_binding
  implicit none

  private

  integer, parameter :: D = c_double

  integer, parameter, public :: &
    & SPUD_REAL      = 0, &
    & SPUD_INTEGER   = 1, &
    & SPUD_NONE      = 2, &
    & SPUD_CHARACTER = 3

  integer, parameter, public :: &
    & SPUD_NO_ERROR                = 0, &
    & SPUD_KEY_ERROR               = 1, &
    & SPUD_TYPE_ERROR              = 2, &
    & SPUD_RANK_ERROR              = 3, &
    & SPUD_SHAPE_ERROR             = 4, &
    & SPUD_NEW_KEY_WARNING         = -1, &
    & SPUD_ATTR_SET_FAILED_WARNING = -2

  public :: &
    & clear_options, &
    & load_options, &
    & write_options, &
    & get_child_name, &
    & number_of_children, &
    & option_count, &
    & have_option, &
    & option_type, &
    & option_rank, &
    & option_shape, &
    & get_option, &
    & add_option, &
    & set_option, &
    & set_option_attribute, &
    & move_option, &
    & copy_option, &
    & delete_option, &
    & print_options

  interface get_option
    module procedure &
      & get_option_real_scalar, &
      & get_option_real_vector, &
      & get_option_real_tensor, &
      & get_option_real_scalar_sp, &
      & get_option_real_vector_sp, &
      & get_option_real_tensor_sp, &
      & get_option_integer_scalar, &
      & get_option_integer_vector, &
      & get_option_integer_tensor, &
      & get_option_character
  end interface

  interface set_option
    module procedure &
      & set_option_real_scalar, &
      & set_option_real_vector, &
      & set_option_real_tensor, &
      & set_option_real_scalar_sp, &
      & set_option_real_vector_sp, &
      & set_option_real_tensor_sp, &
      & set_option_integer_scalar, &
      & set_option_integer_vector, &
      & set_option_integer_tensor, &
      & set_option_character
  end interface

  ! C interfaces
  interface
     subroutine cspud_clear_options() bind(c)
     end subroutine cspud_clear_options

     subroutine cspud_load_options(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
     end subroutine cspud_load_options

     subroutine cspud_write_options(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
     end subroutine cspud_write_options

     function cspud_get_child_name(key, key_len, index, child_name, child_name_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       integer(c_int), intent(in) :: child_name_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int), intent(in) :: index
       character(len=1,kind=c_char), dimension(child_name_len), intent(out) :: child_name
       integer(c_int) :: cspud_get_child_name
     end function cspud_get_child_name

     function cspud_number_of_children(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int) :: cspud_number_of_children
     end function cspud_number_of_children

     function cspud_option_count(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int) :: cspud_option_count
     end function cspud_option_count

     function cspud_have_option(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int) :: cspud_have_option
     end function cspud_have_option

     function cspud_get_option_type(key, key_len, option_type) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int), intent(out) :: option_type
       integer(c_int) :: cspud_get_option_type
     end function cspud_get_option_type

     function cspud_get_option_rank(key, key_len, option_rank) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int), intent(out) :: option_rank
       integer(c_int) :: cspud_get_option_rank
     end function cspud_get_option_rank

     function cspud_get_option_shape(key, key_len, shape) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int), dimension(2), intent(out) :: shape
       integer(c_int) :: cspud_get_option_shape
     end function cspud_get_option_shape

     function cspud_add_option(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int) :: cspud_add_option
     end function cspud_add_option

     function cspud_set_option_attribute(key, key_len, val, val_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       integer(c_int), intent(in) :: val_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       character(len=1,kind=c_char), dimension(val_len), intent(in) :: val
       integer(c_int) :: cspud_set_option_attribute
     end function cspud_set_option_attribute

     function cspud_move_option(key1, key1_len, key2, key2_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key1_len
       integer(c_int), intent(in) :: key2_len
       character(len = 1,kind=c_char), dimension(key1_len), intent(in) :: key1
       character(len = 1,kind=c_char), dimension(key2_len), intent(in) :: key2
       integer(c_int) :: cspud_move_option
     end function cspud_move_option

     function cspud_copy_option(key1, key1_len, key2, key2_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key1_len
       integer(c_int), intent(in) :: key2_len
       character(len = 1,kind=c_char), dimension(key1_len), intent(in) :: key1
       character(len = 1,kind=c_char), dimension(key2_len), intent(in) :: key2
       integer(c_int) :: cspud_copy_option
     end function cspud_copy_option

     function cspud_delete_option(key, key_len) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       integer(c_int) :: cspud_delete_option
     end function cspud_delete_option

     subroutine cspud_print_options() bind(c)
     end subroutine cspud_print_options

     function cspud_get_option(key, key_len, val) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       ! Here intent(in) refers to the c_ptr, not the target!
       type(c_ptr), value, intent(in) :: val
       integer(c_int) :: cspud_get_option
     end function cspud_get_option

     function cspud_set_option(key, key_len, val, type, rank, shape) bind(c)
       use iso_c_binding
       implicit none
       integer(c_int), intent(in) :: key_len
       character(len=1,kind=c_char), dimension(key_len), intent(in) :: key
       type(c_ptr), value, intent(in) :: val
       integer(c_int), intent(in) :: type, rank, shape(*)
       integer(c_int) :: cspud_set_option
     end function cspud_set_option

  end interface

contains

  pure function string_array(string) result(array)
    ! Convert a character array to a string to facilitate C interoperability.
    implicit none
    character(len=*), intent(in) :: string
    character(len=1,kind=c_char), dimension(len(string)) :: array
    
    integer :: i

    do i=1, size(array)
       array(i)=string(i:i)
    end do
    
  end function string_array

  pure function array_string(array) result(string)
    ! Convert a character string to a array to facilitate C interoperability.
    implicit none
    character(len=1,kind=c_char), dimension(:), intent(in) :: array
    character(len=size(array)) :: string

    integer :: i

    do i=1, size(array)
       string(i:i)=array(i)
    end do
    
  end function array_string

  subroutine clear_options()
    call cspud_clear_options
  end subroutine clear_options

  subroutine load_options(filename)
    character(len = * ), intent(in) :: filename

    call cspud_load_options(string_array(filename), len_trim(filename))

  end subroutine load_options

  subroutine write_options(filename)
    character(len = *), intent(in) :: filename

    call cspud_write_options(string_array(filename), len_trim(filename))

  end subroutine write_options

  subroutine get_child_name(key, index, child_name, stat)
    character(len = *), intent(in) :: key
    integer, intent(in) :: index
    character(len = *), intent(out) :: child_name
    integer, optional, intent(out) :: stat

    character(len = 1, kind=c_char), dimension(len(child_name)) :: lchild_name
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lchild_name = ""
    lstat = cspud_get_child_name(string_array(key), len_trim(key), index, lchild_name, len(lchild_name))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

    child_name = trim(array_string(lchild_name))

  end subroutine get_child_name

  function number_of_children(key)
    character(len = *), intent(in) :: key

    integer :: number_of_children

    number_of_children = cspud_number_of_children(string_array(key), len_trim(key))

  end function number_of_children

  function option_count(key)
    character(len = *), intent(in) :: key

    integer :: option_count

    option_count = cspud_option_count(string_array(key), len_trim(key))

  end function option_count

  function have_option(key)
    character(len = *), intent(in) :: key

    logical :: have_option

    have_option = (cspud_have_option(string_array(key), len_trim(key)) /= 0)

  end function have_option

  function option_type(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat

    integer :: option_type

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_get_option_type(string_array(key), len_trim(key), option_type)
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end function option_type

  function option_rank(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat

    integer :: option_rank

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_get_option_rank(string_array(key), len_trim(key), option_rank)
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end function option_rank

  function option_shape(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat

    integer, dimension(2) :: option_shape

    integer :: lstat, shape_store

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_get_option_shape(string_array(key), len_trim(key), option_shape(1:2))  ! Slicing required by GCC 4.2
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

    if(option_rank(key, stat) == 2) then
      shape_store = option_shape(1)
      option_shape(1) = option_shape(2)
      option_shape(2) = shape_store
    end if

  end function option_shape

  subroutine get_option_real_scalar(key, val, stat, default)
    character(len = *), intent(in) :: key
    real(D), intent(out) :: val
    integer, optional, intent(out) :: stat
    real(D), optional, intent(in) :: default

    real(D), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 0, (/-1, -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(key, len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=lval
    end if

  end subroutine get_option_real_scalar

  subroutine get_option_real_vector(key, val, stat, default)
    character(len = *), intent(in) :: key
    real(D), dimension(:), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real(D), dimension(size(val)), optional, intent(in) :: default

    real(D), dimension(size(val)), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 1, (/size(val), -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=lval
    end if

  end subroutine get_option_real_vector

  subroutine get_option_real_tensor(key, val, stat, default)
    character(len = *), intent(in) :: key
    real(D), dimension(:, :), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real(D), dimension(size(val, 1), size(val, 2)), optional, intent(in) :: default

    integer :: lstat
    ! Note the transpose
    real(D), dimension(size(val, 2), size(val, 1)), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 2, shape(val), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=transpose(lval)
    end if

  end subroutine get_option_real_tensor

  subroutine get_option_real_scalar_sp(key, val, stat, default)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, intent(out) :: val
    integer, optional, intent(out) :: stat
    real, optional, intent(in) :: default

    real(D), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 0, (/-1, -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=real(lval)
    end if

  end subroutine get_option_real_scalar_sp

  subroutine get_option_real_vector_sp(key, val, stat, default)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, dimension(:), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real, dimension(size(val)), optional, intent(in) :: default

    integer :: lstat
    real(D), dimension(size(val)), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 1, (/size(val), -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=real(lval)
    end if

  end subroutine get_option_real_vector_sp

  subroutine get_option_real_tensor_sp(key, val, stat, default)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, dimension(:, :), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real, dimension(size(val, 1), size(val, 2)), optional, intent(in) :: default

    integer :: lstat
    real(D), dimension(size(val, 2), size(val, 1)), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_REAL, 2, shape(val), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=real(transpose(lval))
    end if

  end subroutine get_option_real_tensor_sp

  subroutine get_option_integer_scalar(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, intent(out) :: val
    integer, optional, intent(out) :: stat
    integer, optional, intent(in) :: default

    integer :: lstat
    integer(c_int), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_INTEGER, 0, (/-1, -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=lval
    end if

  end subroutine get_option_integer_scalar

  subroutine get_option_integer_vector(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, dimension(:), intent(inout) :: val
    integer, optional, intent(out) :: stat
    integer, dimension(size(val)), optional, intent(in) :: default

    integer(c_int), dimension(size(val)), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_INTEGER, 1, (/size(val), -1/), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=lval
    end if

  end subroutine get_option_integer_vector

  subroutine get_option_integer_tensor(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, dimension(:, :), intent(inout) :: val
    integer, optional, intent(out) :: stat
    integer, dimension(size(val, 1), size(val, 2)), optional, intent(in) :: default

    integer :: lstat
    integer(c_int), dimension(size(val, 2), size(val, 1)), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = default
    else
      call check_option(key, SPUD_INTEGER, 2, shape(val), lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val=transpose(lval)
    end if

  end subroutine get_option_integer_tensor

  subroutine get_option_character(key, val, stat, default)
    character(len = *), intent(in) :: key
    character(len = *), intent(out) :: val
    integer, optional, intent(out) :: stat
    character(len = *), optional, intent(in) :: default

    character(len=1,kind=c_char), dimension(len(val)), target :: lval
    integer :: lstat
    integer, dimension(2) :: lshape

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key) .and. present(default)) then
      val = trim(default)
    else
      call check_option(key, SPUD_CHARACTER, 1, stat = lstat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      lshape = option_shape(key, stat)
      if(lshape(1) > len(val)) then
        call option_error(key, SPUD_SHAPE_ERROR, stat)
        return
      end if
      lval = ""
      lstat = cspud_get_option(string_array(key), len_trim(key), c_loc(lval))
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      val = array_string(lval)
    end if

  end subroutine get_option_character

  subroutine add_option(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_add_option(string_array(key), len_trim(key))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine add_option

  subroutine set_option_real_scalar(key, val, stat)
    character(len = *), intent(in) :: key
    real(D), intent(in), target :: val
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(val), SPUD_REAL, 0, (/-1, -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_scalar

  subroutine set_option_real_vector(key, val, stat)
    character(len = *), intent(in) :: key
    real(D), dimension(:), intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    ! Buffer to make c_loc call legal.
    real(D), dimension(size(val)), target :: lval
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lval=val

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(lval), SPUD_REAL, 1, (/size(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_vector

  subroutine set_option_real_tensor(key, val, stat)
    character(len = *), intent(in) :: key
    real(D), dimension(:, :), intent(in), target :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    real(D), dimension(size(val, 2), size(val, 1)), target :: val_handle

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    val_handle = transpose(val)

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(val_handle), SPUD_REAL, 2, shape(val_handle))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_tensor

  subroutine set_option_real_scalar_sp(key, val, stat)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    real(D), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lval = val
    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(lval), SPUD_REAL, 0, (/-1, -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_scalar_sp

  subroutine set_option_real_vector_sp(key, val, stat)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, dimension(:), intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    real(D), dimension(size(val)), target  :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lval=val
    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(lval), SPUD_REAL, 1, (/size(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_vector_sp

  subroutine set_option_real_tensor_sp(key, val, stat)
    ! Single precision version of routine. Note that values stored in the
    ! dictionary are always double precision.
    character(len = *), intent(in) :: key
    real, dimension(:, :), intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    real(D), dimension(size(val, 2), size(val, 1)), target :: val_handle

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    val_handle = transpose(val)

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(val_handle), SPUD_REAL, 2, shape(val_handle))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_real_tensor_sp

  subroutine set_option_integer_scalar(key, val, stat)
    character(len = *), intent(in) :: key
    integer(c_int), intent(in), target :: val
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(val), SPUD_INTEGER, 0, (/-1, -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_integer_scalar

  subroutine set_option_integer_vector(key, val, stat)
    character(len = *), intent(in) :: key
    integer, dimension(:), intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    integer(c_int), dimension(size(val)), target :: lval

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lval=val

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(lval), SPUD_INTEGER, 1, (/size(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_integer_vector

  subroutine set_option_integer_tensor(key, val, stat)
    character(len = *), intent(in) :: key
    integer, dimension(:, :), intent(in) :: val
    integer, optional, intent(out) :: stat

    integer :: lstat
    integer, dimension(size(val, 2), size(val, 1)), target :: val_handle

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    val_handle = transpose(val)

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(val_handle), SPUD_INTEGER, 2, shape(val_handle))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_integer_tensor

  subroutine set_option_character(key, val, stat)
    character(len = *), intent(in) :: key
    character(len = *), intent(in) :: val
    integer, optional, intent(out) :: stat

    character(len=1,kind=c_char), dimension(len(val)), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lval=string_array(val)

    lstat = cspud_set_option(string_array(key), len_trim(key), c_loc(lval), SPUD_CHARACTER, 1, (/len_trim(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_character

  subroutine set_option_attribute(key, val, stat)
    character(len = *), intent(in) :: key
    character(len = *), intent(in) :: val
    integer, optional, intent(out) :: stat

    character(len=1,kind=c_char), dimension(len(val)), target :: lval
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lval=string_array(val)

    lstat = cspud_set_option_attribute(string_array(key), len_trim(key), lval, len_trim(val))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine set_option_attribute

  subroutine move_option(key1, key2, stat)
    character(len = *), intent(in) :: key1
    character(len = *), intent(in) :: key2
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_move_option(string_array(key1), len_trim(key1), string_array(key2), len_trim(key2))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key1, lstat, stat)
      return
    end if

  end subroutine move_option

  subroutine copy_option(key1, key2, stat)
    character(len = *), intent(in) :: key1
    character(len = *), intent(in) :: key2
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_copy_option(string_array(key1), len_trim(key1), string_array(key2), len_trim(key2))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key1, lstat, stat)
      return
    end if

  end subroutine copy_option

  subroutine delete_option(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat

    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = cspud_delete_option(string_array(key), len_trim(key))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

  end subroutine delete_option

  subroutine print_options()

    call cspud_print_options()

  end subroutine print_options

  subroutine option_error(key, error, stat)
    !!< Handle option errors

    character(len = *), intent(in) :: key
    ! Error code
    integer, intent(in) :: error
    ! Optional stat argument - die if error and it's not present
    integer, optional, intent(out) :: stat

    if(present(stat)) then
      stat = error
      return
    end if

    select case(error)
      case(SPUD_NO_ERROR)
        return
      case(SPUD_KEY_ERROR)
        write(0, *) "Option key error. Key is: " // trim(key)
      case(SPUD_TYPE_ERROR)
        write(0, *) "Option type error. Key is: " // trim(key)
      case(SPUD_RANK_ERROR)
        write(0, *) "Option rank error. Key is: " // trim(key)
      case(SPUD_SHAPE_ERROR)
        write(0, *) "Option shape error. Key is: " // trim(key)
      case(SPUD_NEW_KEY_WARNING)
        write(0, *) "Option warning. Key is not in the options tree: " // trim(key)
      case(SPUD_ATTR_SET_FAILED_WARNING)
        write(0, *) "Option warning. Option cannot be set as an attribute. Key is " // trim(key)
      case default
        write(0, *) "Unknown option error. Key is: " // trim(key)
    end select

    stop

  end subroutine option_error

  subroutine check_option(key, type, rank, shape, stat)
    !!< Check existence, type, rank, and optionally shape, of the option with
    !!< the supplied key

    character(len = *), intent(in) :: key
    integer, intent(in) :: type
    integer, intent(in) :: rank
    integer, dimension(2), optional, intent(in) :: shape
    integer, optional, intent(out) :: stat

    integer :: i, lrank, lstat, ltype
    integer, dimension(2) :: lshape

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    if(.not. have_option(key)) then
      call option_error(key, SPUD_KEY_ERROR, stat)
      return
    end if

    ltype = option_type(key, lstat)
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

    lrank = option_rank(key, lstat)
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

    if(type /= ltype) then
      call option_error(key, SPUD_TYPE_ERROR, stat)
      return
    else if(rank /= lrank) then
      call option_error(key, SPUD_RANK_ERROR, stat)
      return
    else if(present(shape)) then
      lshape = option_shape(key, stat)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if

      do i = 1, rank
        if(shape(i) /= lshape(i)) then
          call option_error(key, SPUD_SHAPE_ERROR, stat)
          return
        end if
      end do
    end if

  end subroutine check_option

end module spud
