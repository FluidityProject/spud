!    Copyright (C) 2007 Imperial College London and others.
!    
!    Please see the AUTHORS file in the main source directory for a full list
!    of copyright holders.
!
!    Prof. C Pain
!    Applied Modelling and Computation Group
!    Department of Earth Science and Engineering
!    Imperial College London
!
!    C.Pain@Imperial.ac.uk
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
  !!< This module provides a dictionary object for options whose entries
  !!< can contain a wide variety of data.
  
  implicit none
  
  private
  
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
    & delete_option

  interface get_option
    module procedure &
      & get_option_real_scalar, &
      & get_option_real_vector, &
      & get_option_real_tensor, &
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
      & set_option_integer_scalar, &
      & set_option_integer_vector, &
      & set_option_integer_tensor, &
      & set_option_character
  end interface
  
  !! C interfaces
  interface  
    subroutine spud_load_options(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
    end subroutine spud_load_options
    
    subroutine spud_write_options(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
    end subroutine spud_write_options
    
    function spud_get_child_name(key, key_len, index, child_name, child_name_len)
      integer, intent(in) :: key_len
      integer, intent(in) :: child_name_len
      character(len = key_len), intent(in) :: key
      integer, intent(in) :: index
      character(len = child_name_len), intent(out) :: child_name
      integer :: spud_get_child_name
    end function spud_get_child_name
    
    function spud_number_of_children(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer :: spud_number_of_children
    end function spud_number_of_children
    
    function spud_option_count(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer :: spud_option_count
    end function spud_option_count
    
    function spud_have_option(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer :: spud_have_option
    end function spud_have_option
    
    function spud_get_option_type(key, key_len, option_type)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer, intent(out) :: option_type
      integer :: spud_get_option_type
    end function spud_get_option_type
    
    function spud_get_option_rank(key, key_len, option_rank)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer, intent(out) :: option_rank
      integer :: spud_get_option_rank
    end function spud_get_option_rank
    
    function spud_get_option_shape(key, key_len, shape)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer, dimension(2), intent(out) :: shape
      integer :: spud_get_option_shape
    end function spud_get_option_shape
    
    function spud_add_option(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer :: spud_add_option
    end function spud_add_option
    
    function spud_set_option_attribute(key, key_len, val, val_len)
      integer, intent(in) :: key_len
      integer, intent(in) :: val_len
      character(len = key_len), intent(in) :: key
      character(len = val_len), intent(in) :: val
      integer :: spud_set_option_attribute
    end function spud_set_option_attribute
    
    function spud_delete_option(key, key_len)
      integer, intent(in) :: key_len
      character(len = key_len), intent(in) :: key
      integer :: spud_delete_option
    end function spud_delete_option
  end interface

  !! Implicitly interfaced as can take multiple argument types
  integer, external :: spud_get_option, spud_set_option

contains

  subroutine load_options(filename)  
    character(len = * ), intent(in) :: filename

    call spud_load_options(filename, len_trim(filename))
    
  end subroutine load_options
  
  subroutine write_options(filename)
    character(len = *), intent(in) :: filename
    
    call spud_write_options(filename, len_trim(filename))
    
  end subroutine write_options

  subroutine get_child_name(key, index, child_name, stat)    
    character(len = *), intent(in) :: key
    integer, intent(in) :: index
    character(len = *), intent(out) :: child_name
    integer, optional, intent(out) :: stat
   
    character(len = len(child_name)) :: lchild_name
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lchild_name = ""
    lstat = spud_get_child_name(key, len_trim(key), index, lchild_name, len(lchild_name))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if

    child_name = trim(lchild_name)
    
  end subroutine get_child_name
  
  function number_of_children(key)    
    character(len = *), intent(in) :: key
    
    integer :: number_of_children
    
    number_of_children = spud_number_of_children(key, len_trim(key))
    
  end function number_of_children
  
  function option_count(key)    
    character(len = *), intent(in) :: key
    
    integer :: option_count
    
    option_count = spud_option_count(key, len_trim(key))
        
  end function option_count
  
  function have_option(key)
    character(len = *), intent(in) :: key
    
    logical :: have_option
    
    have_option = (spud_have_option(key, len_trim(key)) /= 0)

  end function have_option
  
  function option_type(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat
    
    integer :: option_type
    
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if

    lstat = spud_get_option_type(key, len_trim(key), option_type)
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

    lstat = spud_get_option_rank(key, len_trim(key), option_rank)
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
    
    lstat = spud_get_option_shape(key, len_trim(key), option_shape)
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
    shape_store = option_shape(1)
    option_shape(1) = option_shape(2)
    option_shape(2) = shape_store
    
  end function option_shape
  
  subroutine get_option_real_scalar(key, val, stat, default)
    character(len = *), intent(in) :: key
    real, intent(out) :: val
    integer, optional, intent(out) :: stat
    real, optional, intent(in) :: default
    
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
      lstat = spud_get_option(key, len_trim(key), val)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
    end if
  
  end subroutine get_option_real_scalar
  
  subroutine get_option_real_vector(key, val, stat, default)
    character(len = *), intent(in) :: key
    real, dimension(:), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real, dimension(size(val)), optional, intent(in) :: default
    
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
      lstat = spud_get_option(key, len_trim(key), val)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
    end if
  
  end subroutine get_option_real_vector
  
  subroutine get_option_real_tensor(key, val, stat, default)
    character(len = *), intent(in) :: key
    real, dimension(:, :), intent(inout) :: val
    integer, optional, intent(out) :: stat
    real, dimension(size(val, 1), size(val, 2)), optional, intent(in) :: default
    
    integer :: i, j, lstat
    real, dimension(size(val, 2), size(val, 1)) :: val_handle
    
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
      lstat = spud_get_option(key, len_trim(key), val_handle)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      do i = 1, size(val, 1)
        do j = 1, size(val, 2)
          val(i, j) = val_handle(j, i)
        end do
      end do
    end if
  
  end subroutine get_option_real_tensor
  
  subroutine get_option_integer_scalar(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, intent(out) :: val
    integer, optional, intent(out) :: stat
    integer, optional, intent(in) :: default
    
    integer :: lstat
    
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
      lstat = spud_get_option(key, len_trim(key), val)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
    end if
  
  end subroutine get_option_integer_scalar
  
  subroutine get_option_integer_vector(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, dimension(:), intent(inout) :: val
    integer, optional, intent(out) :: stat
    integer, dimension(size(val)), optional, intent(in) :: default
    
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
      lstat = spud_get_option(key, len_trim(key), val)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
    end if
  
  end subroutine get_option_integer_vector
  
  subroutine get_option_integer_tensor(key, val, stat, default)
    character(len = *), intent(in) :: key
    integer, dimension(:, :), intent(inout) :: val
    integer, optional, intent(out) :: stat
    integer, dimension(size(val, 1), size(val, 2)), optional, intent(in) :: default
    
    integer :: i ,j, lstat
    integer, dimension(size(val, 2), size(val, 1)) :: val_handle
    
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
      lstat = spud_get_option(key, len_trim(key), val_handle)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if
      do i = 1, size(val, 1)
        do j = 1, size(val, 2)
          val(i, j) = val_handle(j, i)
        end do
      end do
    end if
  
  end subroutine get_option_integer_tensor
  
  subroutine get_option_character(key, val, stat, default)
    character(len = *), intent(in) :: key
    character(len = *), intent(out) :: val
    integer, optional, intent(out) :: stat
    character(len = *), optional, intent(in) :: default
   
    character(len = len(val)) :: lval
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
      lstat = spud_get_option(key, len_trim(key), lval)
      if(lstat /= SPUD_NO_ERROR) then
        call option_error(key, lstat, stat)
        return
      end if

      val = trim(lval)
    end if
    
  end subroutine get_option_character
  
  subroutine add_option(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_add_option(key, len_trim(key))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine add_option
  
  subroutine set_option_real_scalar(key, val, stat)
    character(len = *), intent(in) :: key
    real, intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option(key, len_trim(key), val, SPUD_REAL, 0, (/-1, -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
  
  end subroutine set_option_real_scalar
  
  subroutine set_option_real_vector(key, val, stat)
    character(len = *), intent(in) :: key
    real, dimension(:), intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: lstat

    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option(key, len_trim(key), val, SPUD_REAL, 1, (/size(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine set_option_real_vector
  
  subroutine set_option_real_tensor(key, val, stat)
    character(len = *), intent(in) :: key
    real, dimension(:, :), intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: i, j, lstat
    real, dimension(size(val, 2), size(val, 1)) :: val_handle
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    do i = 1, size(val, 1)
      do j = 1, size(val, 2)
        val_handle(j, i) = val(i, j)
      end do
    end do
    
    lstat = spud_set_option(key, len_trim(key), val_handle, SPUD_REAL, 2, shape(val_handle))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine set_option_real_tensor
  
  subroutine set_option_integer_scalar(key, val, stat)
    character(len = *), intent(in) :: key
    integer, intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option(key, len_trim(key), val, SPUD_INTEGER, 0, (/-1, -1/))
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
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option(key, len_trim(key), val, SPUD_INTEGER, 1, (/size(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine set_option_integer_vector
  
  subroutine set_option_integer_tensor(key, val, stat)
    character(len = *), intent(in) :: key
    integer, dimension(:, :), intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: i, j, lstat
    integer, dimension(size(val, 2), size(val, 1)) :: val_handle
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    do i = 1, size(val, 1)
      do j = 1, size(val, 2)
        val_handle(j, i) = val(i, j)
      end do
    end do
    
    lstat = spud_set_option(key, len_trim(key), val_handle, SPUD_INTEGER, 2, shape(val_handle))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine set_option_integer_tensor
  
  subroutine set_option_character(key, val, stat)
    character(len = *), intent(in) :: key
    character(len = *), intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option(key, len_trim(key), val, SPUD_CHARACTER, 1, (/len_trim(val), -1/))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine set_option_character
  
  subroutine set_option_attribute(key, val, stat)
    character(len = *), intent(in) :: key
    character(len = *), intent(in) :: val
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_set_option_attribute(key, len_trim(key), val, len_trim(val))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
  
  end subroutine set_option_attribute
  
  subroutine delete_option(key, stat)
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat
    
    integer :: lstat
    
    if(present(stat)) then
      stat = SPUD_NO_ERROR
    end if
    
    lstat = spud_delete_option(key, len_trim(key))
    if(lstat /= SPUD_NO_ERROR) then
      call option_error(key, lstat, stat)
      return
    end if
    
  end subroutine delete_option
        
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
    !!< Check key existence, type, rank, and optionally shape, of the option
    !!< with the supplied key
  
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
