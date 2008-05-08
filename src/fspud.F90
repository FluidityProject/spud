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

  integer, parameter, public :: SPUD_REAL=0, SPUD_INTEGER=1,&
       & SPUD_LOGICAL=2, SPUD_NONE=3, SPUD_CHARACTER=4

  integer, parameter, public :: SPUD_KEY_ERROR=1, SPUD_TYPE_ERROR=2,&
       & SPUD_RANK_ERROR=3, SPUD_SHAPE_ERROR=4, SPUD_NEW_KEY_WARNING=5, SPUD_ATTR_SET_FAILED_WARNING=6

  interface get_option
     module procedure get_option_real_scalar,&
          get_option_real_vector, &
          get_option_real_tensor, &
          get_option_integer_scalar,&
          get_option_integer_vector,&
          get_option_integer_tensor,&
          get_option_logical_scalar,&
          get_option_character
  end interface

  interface set_option
     module procedure set_option_real_scalar ,&
          set_option_real_vector, &
          set_option_real_tensor, &
          set_option_integer_scalar,&
          set_option_integer_vector,&
          set_option_integer_tensor,&
          set_option_logical_scalar ,&
          set_option_character
  end interface

  private
  public get_child_name, number_of_children, get_option, &
       option_count, have_option, option_rank, option_shape, &
       option_type, option_error, add_option, set_option, &
       set_option_attribute, delete_option, &
       load_options, write_options

  interface 
     !! C interface to dictionary inquiry function.
     integer function cget_option_info(key, len, shape, rank, type)
       integer, intent(in) :: len
       character(len=len), intent(in) :: key
       integer, intent(out) :: rank
       integer, dimension(2), intent(out) :: shape
       integer, intent(out) :: type
     end function cget_option_info
  end interface

  interface 
     !! C interface to dictionary loading function.
     integer function cget_load_option(key, len)
       integer, intent(in) :: len
       character(len=len), intent(in) :: key
     end function cget_load_option
  end interface

  !! Deliberately leave the interface to cget_option implicit so we can
  !! play silly buggers with the argument types.
  integer :: cget_option
  external :: cget_option

  integer :: chave_option
  external :: chave_option
  
  integer :: cadd_option
  external :: cadd_option

  integer :: cset_option
  external :: cset_option
  
  integer :: cset_option_is_attribute
  external :: cset_option_is_attribute
  
  integer :: cdelete_option
  external :: cdelete_option

  external :: cload_option

contains

  subroutine load_options(filename)
    character(len=*), intent(in) :: filename
    external :: cload_option

    call cload_option(filename, len_trim(filename))
  end subroutine load_options
  
  subroutine write_options(filename)
    character(len=*), intent(in) :: filename
    external :: cwrite_option
    
    call cwrite_option(filename, len_trim(filename))
  end subroutine write_options

  subroutine get_child_name(key, index, child_name)
    external cget_child_name
    integer cget_child_name
    
    character(len=*), intent(in)::key
    integer, intent(in)::index
    character(len=*), intent(out)::child_name
    
    integer :: lstat

    child_name = " "
    lstat = cget_child_name(key, len_trim(key), index, child_name)
  end subroutine get_child_name

  function number_of_children(key)
    external cget_number_of_children
    integer cget_number_of_children
    
    character(len=*), intent(in) :: key
    integer :: number_of_children
    integer :: lstat
    
    lstat = cget_number_of_children(key, len_trim(key), number_of_children)
    
  end function number_of_children

  function option_count(key)
    external cget_option_count
    integer cget_option_count
    
    character(len=*), intent(in) :: key
    integer :: option_count
    integer :: lstat
    
    lstat = cget_option_count(key, len_trim(key), option_count)
    
  end function option_count

  function have_option(key)
    !!< Test for the presence of the option given by key.
    logical :: have_option
    character(len=*), intent(in) :: key

    integer :: rank
    integer, dimension(2) :: lshape
    integer :: type
    integer :: lstat

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    have_option=(chave_option(key, len_trim(key))==1)

  end function have_option

  function option_type(key, stat) result (type)
    !!< Return the type of the option given by key.
    integer :: type
    character(len=*), intent(in) :: key
    integer, intent(out), optional :: stat

    integer :: rank
    integer, dimension(2) :: lshape
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if

  end function option_type

  function option_rank(key, stat) result (rank)
    !!< Return the rank of the option given by key.
    integer :: rank
    character(len=*), intent(in) :: key
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if

  end function option_rank

  function option_shape(key, stat) result (lshape)
    !!< Return the rank of the option given by key.
    integer, dimension(2) :: lshape
    character(len=*), intent(in) :: key
    integer, intent(out), optional :: stat

    integer :: type
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if

  end function option_shape
  
  subroutine get_option_real_scalar(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    real, intent(out) :: option
    integer, intent(out), optional :: stat
    real, intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=0) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_REAL) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_real_scalar

  subroutine get_option_real_vector(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    real, dimension(:), intent(out) :: option
    integer, intent(out), optional :: stat
    real, intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=1) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_REAL) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if
    if (lshape(1)/=size(option)) then
       call option_error(key, SPUD_SHAPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_real_vector

  subroutine get_option_real_tensor(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    real, dimension(:,:), intent(out) :: option
    integer, intent(out), optional :: stat
    real, intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=2) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_REAL) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if
    if (lshape(1)/=size(option,1) .or. lshape(2)/=size(option,2)) then
       call option_error(key, SPUD_SHAPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_real_tensor

  subroutine get_option_integer_scalar(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    integer, intent(out) :: option
    integer, intent(out), optional :: stat
    integer, intent(in), optional :: default
 
    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=0) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_INTEGER) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_integer_scalar

  subroutine get_option_integer_vector(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    integer, dimension(:), intent(out) :: option
    integer, intent(out), optional :: stat
    integer, intent(in), optional :: default
 
    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=1) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_INTEGER) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if
    if (lshape(1)/=size(option)) then
       call option_error(key, SPUD_SHAPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_integer_vector

  subroutine get_option_integer_tensor(key, option, stat, default)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    integer, dimension(:,:), intent(out) :: option
    integer, intent(out), optional :: stat
    integer, intent(in), optional :: default
 
    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=2) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_INTEGER) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if
    if (lshape(1)/=size(option,1) .or. lshape(2)/=size(option,2)) then
       call option_error(key, SPUD_SHAPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine get_option_integer_tensor

  subroutine get_option_logical_scalar(key, option, stat)
    !!< Return the value of the option given by key
    character(len=*), intent(in) :: key
    logical, intent(out) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if
    if (rank/=0) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_LOGICAL) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if

    lstat=cget_option(key, len_trim(key), option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if
    
  end subroutine get_option_logical_scalar

  subroutine get_option_character(key, option, stat, default)
    !!< Return the value of the option given by key
    !!<
    !!< Note that due to the limitations of C strings, only scalar string
    !!< options are possible.
    character(len=*), intent(in) :: key
    character(len=*), intent(out) :: option
    integer, intent(out), optional :: stat
    character(len=*), intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(default)) then
          option=default
          return
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    end if
    if (rank/=1) then
       call option_error(key, SPUD_RANK_ERROR, stat)
       return
    end if
    if (type/=SPUD_CHARACTER) then
       call option_error(key, SPUD_TYPE_ERROR, stat)
       return
    end if

    option=" "
    lstat=cget_option(key, len_trim(key), option)
    
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
       return
    end if
    
  end subroutine get_option_character

  subroutine option_error(key, error, stat)
    !!< Handle option errors in a nice way.
    character(len=*), intent(in) :: key
    ! Error code.
    integer, intent(in) :: error
    ! Optional stat argument: die if it's not present.
    integer, intent(out), optional :: stat
    
    character(len=666) :: buffer

    if (present(stat)) then
       stat=error
       return
    end if
    
    select case (error)
    case (SPUD_KEY_ERROR)
       buffer="Option key error. Key is: "//trim(key)
    case (SPUD_TYPE_ERROR)
       buffer="Option type error. Key is: "//trim(key)
    case (SPUD_RANK_ERROR)
       buffer="Option rank error. Key is: "//trim(key)       
    case (SPUD_SHAPE_ERROR)
       buffer="Option shape error. Key is: "//trim(key)       
    case (SPUD_NEW_KEY_WARNING)
       buffer="Option warning. Key is not in the options tree: "//trim(key)
    case (SPUD_ATTR_SET_FAILED_WARNING)
      buffer = "Option warning. Option cannot be set as an attribute. Key is " // trim(key)
    end select

    write(0,*) trim(buffer)
    stop
    
  end subroutine option_error

  subroutine add_option(key, stat)
    !!< Add an option specified by key
    
    character(len = *), intent(in) :: key
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if(present(stat)) then
      stat=0
    end if

    lstat = cget_option_info(key, len_trim(key), lshape, rank, type)

    if(lstat /= 0) then
      if(present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    end if

    lstat = cadd_option(key, len_trim(key))
    if (lstat /= 0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  
  end subroutine add_option

  subroutine set_option_real_scalar(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    real, intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=0) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_REAL) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), 0, 0, SPUD_REAL, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_real_scalar

  subroutine set_option_real_vector(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    real, dimension(:), intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=1) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_REAL) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), size(option), 1, SPUD_REAL, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_real_vector

  subroutine set_option_real_tensor(key, option, stat, default)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    real, dimension(:,:), intent(in) :: option
    integer, intent(out), optional :: stat
    real, intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(stat)) then
          call option_error(key, SPUD_NEW_KEY_WARNING, stat)
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    else
       if (rank/=2) then
          call option_error(key, SPUD_RANK_ERROR, stat)
          return
       end if
       if (type/=SPUD_REAL) then
          call option_error(key, SPUD_TYPE_ERROR, stat)
          return
       end if
       if (lshape(1)/=size(option,1) .or. lshape(2)/=size(option,2)) then
          call option_error(key, SPUD_SHAPE_ERROR, stat)
          return
       end if
    end if

    lstat=cset_option(key, len_trim(key), shape(option), 2, SPUD_REAL,&
         & option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine set_option_real_tensor

  subroutine set_option_integer_scalar(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    integer, intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=0) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_INTEGER) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), 0, 0, SPUD_INTEGER, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_integer_scalar

  subroutine set_option_integer_vector(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    integer, dimension(:), intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=1) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_INTEGER) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), size(option), 1, SPUD_INTEGER, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_integer_vector

  subroutine set_option_integer_tensor(key, option, stat, default)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    integer, dimension(:,:), intent(in) :: option
    integer, intent(out), optional :: stat
    integer, intent(in), optional :: default

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
       if (present(stat)) then
          call option_error(key, SPUD_NEW_KEY_WARNING, stat)
       else
          call option_error(key, SPUD_KEY_ERROR, stat)
          return
       end if
    else
       if (rank/=2) then
          call option_error(key, SPUD_RANK_ERROR, stat)
          return
       end if
       if (type/=SPUD_INTEGER) then
          call option_error(key, SPUD_TYPE_ERROR, stat)
          return
       end if
       if (lshape(1)/=size(option,1) .or. lshape(2)/=size(option,2)) then
          call option_error(key, SPUD_SHAPE_ERROR, stat)
          return
       end if
    end if

    lstat=cset_option(key, len_trim(key), shape(option), 2, SPUD_INTEGER,&
         & option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
    
  end subroutine set_option_integer_tensor

  subroutine set_option_logical_scalar(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    logical, intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=0) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_LOGICAL) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), 0, 0, SPUD_LOGICAL, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_logical_scalar

  subroutine set_option_character(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    character(len=*), intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: type
    integer, dimension(2) :: lshape
    integer :: rank
    integer :: lstat

    if (present(stat)) stat=0

    lstat=cget_option_info(key, len_trim(key), lshape, rank, type)

    if (lstat/=0) then
      if (present(stat)) then
        call option_error(key, SPUD_NEW_KEY_WARNING, stat)
      else
        call option_error(key, SPUD_KEY_ERROR, stat)
        return
      end if
    else
      if (rank/=1) then
         call option_error(key, SPUD_RANK_ERROR, stat)
         return
      end if

      if (type/=SPUD_CHARACTER) then
         call option_error(key, SPUD_TYPE_ERROR, stat)
         return
      end if
    end if

    lstat=cset_option(key, len_trim(key), len(option), 1, SPUD_CHARACTER, option)
    if (lstat/=0) then
       call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  end subroutine set_option_character
  
  subroutine set_option_attribute(key, option, stat)
    !!< Set the value of the option given by key
    character(len=*), intent(in) :: key
    character(len=*), intent(in) :: option
    integer, intent(out), optional :: stat

    integer :: is_attribute, lstat

    if (present(stat)) stat=0
    
    call set_option_character(key, option, stat)
    
    lstat = cset_option_is_attribute(key, len_trim(key), 1, is_attribute)
    if(lstat /= 0) then
      call option_error(key, SPUD_KEY_ERROR, stat)
    else if(is_attribute /= 1) then
      call option_error(key, SPUD_ATTR_SET_FAILED_WARNING, stat)
    end if
    
  end subroutine set_option_attribute
  
  subroutine delete_option(key, stat)
    !!< Delete the option specified by key, together with all of its children.
  
    character(len = *), intent(in) :: key
    integer, optional, intent(out) :: stat
    
    integer :: lstat

    if(present(stat)) stat = 0

    lstat = cdelete_option(key, len_trim(key))
    if(lstat /= 0) then
      call option_error(key, SPUD_KEY_ERROR, stat)
    end if
  
  end subroutine delete_option
  
end module spud
