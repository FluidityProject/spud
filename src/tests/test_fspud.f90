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

subroutine test_fspud

  use spud
  use unittest_tools

  implicit none

  integer, parameter :: D = kind(0.0D0)
  real(D), parameter :: tol = 1.0e-6
    
  call set_and_get_tests("/real_scalar", test_real_scalar = 42.0_D)
  call set_and_get_tests("/real_vector", test_real_vector = (/42.0_D, 43.0_D/))
  call set_and_get_tests("/real_tensor", test_real_tensor = reshape((/42.0_D, 43.0_D, 44.0_D, 45.0_D, 46.0_D, 47.0_D/), (/2, 3/)))
  call set_and_get_tests("/integer_scalar", test_integer_scalar = 42)
  call set_and_get_tests("/integer_vector", test_integer_vector = (/42, 43/))
  call set_and_get_tests("/integer_tensor", test_integer_tensor = reshape((/42, 43, 44, 45, 46, 47/), (/2, 3/)))
  call set_and_get_tests("/character", test_char = "Forty Two")
  call set_and_get_tests("/type_none")
  
contains

  subroutine set_and_get_tests(key, test_real_scalar, test_real_vector, test_real_tensor, test_integer_scalar, test_integer_vector, test_integer_tensor, test_char)
    character(len = *), intent(in) :: key
    real(D), optional, intent(in) :: test_real_scalar
    real(D), dimension(:), optional, intent(in) :: test_real_vector
    real(D), dimension(:, :), optional, intent(in) :: test_real_tensor
    integer, optional, intent(in) :: test_integer_scalar
    integer, dimension(:), optional, intent(in) :: test_integer_vector
    integer, dimension(:, :), optional, intent(in) :: test_integer_tensor
    character(len = *), optional, intent(in) :: test_char
    
    integer :: type, rank
    integer, dimension(2) :: shape
    
    character(len = 0) :: short_char
    character(len = len(test_char)) :: ltest_char
    integer :: ltest_integer_scalar
    integer, dimension(:), allocatable :: ltest_integer_vector, default_integer_vector
    integer, dimension(:, :), allocatable :: ltest_integer_tensor, default_integer_tensor
    real(D) :: ltest_real_scalar
    real(D), dimension(:), allocatable :: ltest_real_vector, default_real_vector
    real(D), dimension(:, :), allocatable :: ltest_real_tensor, default_real_tensor
    integer :: i, lrank, ltype, stat
    integer, dimension(2) :: lshape
    
    if(present(test_real_scalar)) then
      type = SPUD_REAL
      rank = 0
      shape = (/-1, -1/)
      print *, "*** SET TESTS FOR REAL SCALAR ***"
    else if(present(test_real_vector)) then
      type = SPUD_REAL
      rank = 1
      shape = (/size(test_real_vector), -1/)
      print *, "*** SET TESTS FOR REAL VECTOR ***"
    else if(present(test_real_tensor)) then
      type = SPUD_REAL
      rank = 2
      shape = (/size(test_real_tensor, 1), size(test_real_tensor, 2)/)
      print *, "*** SET TESTS FOR REAL TENSOR ***"
    else if(present(test_integer_scalar)) then
      type = SPUD_INTEGER
      rank = 0
      shape = (/-1, -1/)
      print *, "*** SET TESTS FOR INTEGER SCALAR ***"
    else if(present(test_integer_vector)) then
      type = SPUD_INTEGER
      rank = 1
      shape = (/size(test_integer_vector), -1/)
      print *, "*** SET TESTS FOR INTEGER VECTOR ***"
    else if(present(test_integer_tensor)) then
      type = SPUD_INTEGER
      rank = 2
      shape = (/size(test_integer_tensor, 1), size(test_integer_tensor, 2)/)
      print *, "*** SET TESTS FOR INTEGER TENSOR ***"
    else if(present(test_char)) then
      type = SPUD_CHARACTER
      rank = 1
      shape = (/len(test_char), -1/)
      print *, "*** SET TESTS FOR CHARACTER ***"
    else
      type = SPUD_NONE
      rank = -1
      shape = (/-1, -1/)
      print *, "*** SET TESTS FOR TYPE NONE ***"
    end if

    call key_error_tests(key)
    
    do i = 1, 2
      select case(i)
        case(1)
          if(present(test_real_scalar)) then
            call set_option(trim(key), test_real_scalar, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_real_vector)) then
            call set_option(trim(key), test_real_vector, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_real_tensor)) then
            call set_option(trim(key), test_real_tensor, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_integer_scalar)) then
            call set_option(trim(key), test_integer_scalar, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_integer_vector)) then
            call set_option(trim(key), test_integer_vector, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_integer_tensor)) then
            call set_option(trim(key), test_integer_tensor, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else if(present(test_char)) then
            call set_option(trim(key), test_char, stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
          else
            call add_option(trim(key), stat)
            call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when adding option")
          end if
        case default
          if(present(test_real_scalar)) then
            call set_option(trim(key), test_real_scalar, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_real_vector)) then
            call set_option(trim(key), test_real_vector, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_real_tensor)) then
            call set_option(trim(key), test_real_tensor, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_integer_scalar)) then
            call set_option(trim(key), test_integer_scalar, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_integer_vector)) then
            call set_option(trim(key), test_integer_vector, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_integer_tensor)) then
            call set_option(trim(key), test_integer_tensor, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else if(present(test_char)) then
            call set_option(trim(key), test_char, stat)
            call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
          else
            call add_option(trim(key), stat)
            call report_test("[Add existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when adding option")
          end if
      end select
    
      call report_test("[Option present]", .not. have_option(trim(key)), .false., "Present option reported missing")
      ltype = option_type(trim(key), stat)
      call report_test("[Extracted option type]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option type")
      call report_test("[Correct option type]", ltype /= type, .false., "Incorrect option type returned")
      lrank = option_rank(trim(key), stat)
      call report_test("[Extracted option rank]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option rank")
      call report_test("[Correct option rank]", lrank /= rank, .false., "Incorrect option rank returned")
      lshape = option_shape(trim(key), stat)
      call report_test("[Extracted option shape]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option shape")
      call report_test("[Correct option shape]", count(lshape /= shape) /= 0, .false., "Incorrect option shape returned")
       
      if(type == SPUD_REAL) then
        if(rank == 0) then
          call get_option(trim(key), ltest_real_scalar, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", abs(ltest_real_scalar - test_real_scalar) > tol, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_real_scalar, stat, default = test_real_scalar + 1.0_D)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", abs(ltest_real_scalar - test_real_scalar) > tol, .false., "Retrieved incorrect option data")
        else
          call get_option(trim(key), ltest_real_scalar, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          call get_option(trim(key), ltest_real_scalar, stat, default = 0.0_D)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
        end if
        if(rank == 1) then
          allocate(ltest_real_vector(shape(1)))
          call get_option(trim(key), ltest_real_vector, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", maxval(abs(ltest_real_vector - test_real_vector)) > tol, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_real_vector, stat, default = test_real_vector + 1.0_D)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", maxval(abs(ltest_real_vector - test_real_vector)) > tol, .false., "Retrieved incorrect option data")
          deallocate(ltest_real_vector)
          allocate(ltest_real_vector(shape(1) + 1))
          call get_option(trim(key), ltest_real_vector, stat)
          call report_test("[Shape error when extracting option data]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          allocate(default_real_vector(shape(1)))
          default_real_vector = 0.0_D
          call get_option(trim(key), ltest_real_vector, stat, default = default_real_vector)
          call report_test("[Shape error when extracting option data with default argument]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_real_vector)
          deallocate(ltest_real_vector)
        else
          allocate(ltest_real_vector(3))
          call get_option(trim(key), ltest_real_vector, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          allocate(default_real_vector(shape(1)))
          default_real_vector = 0.0_D
          call get_option(trim(key), ltest_real_vector, stat, default = default_real_vector)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_real_vector)
          deallocate(ltest_real_vector)
        end if
        if(rank == 2) then
          allocate(ltest_real_tensor(shape(1), shape(2)))
          call get_option(trim(key), ltest_real_tensor, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", maxval(abs(ltest_real_tensor - test_real_tensor)) > tol, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_real_tensor, stat, default = test_real_tensor + 1.0_D)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", maxval(abs(ltest_real_tensor - test_real_tensor)) > tol, .false., "Retrieved incorrect option data")
          deallocate(ltest_real_tensor)
          allocate(ltest_real_tensor(shape(1) + 1, shape(2) + 1))
          call get_option(trim(key), ltest_real_tensor, stat)
          call report_test("[Shape error when extracting option data]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          allocate(default_real_tensor(shape(1) + 1, shape(2) + 1))
          default_real_tensor = 0.0_D
          call get_option(trim(key), ltest_real_tensor, stat, default = default_real_tensor)
          call report_test("[Shape error when extracting option data with default argument]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_real_tensor)
          deallocate(ltest_real_tensor)
        else
          allocate(ltest_real_tensor(3, 4))
          call get_option(trim(key), ltest_real_tensor, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          allocate(default_real_tensor(shape(1), shape(2)))
          default_real_tensor = 0.0_D
          call get_option(trim(key), ltest_real_tensor, stat, default = default_real_tensor)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_real_tensor)
          deallocate(ltest_real_tensor)
        end if        
      else
        allocate(ltest_real_vector(3))
        allocate(ltest_real_tensor(3, 4))
        allocate(default_real_vector(3))      
        default_real_vector = 0.0_D
        allocate(default_real_tensor(3, 4)) 
        default_real_tensor = 0.0_D
        call get_option(trim(key), ltest_real_scalar, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_scalar, stat, default = 0.0_D)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_vector, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_vector, stat, default = default_real_vector)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_tensor, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_tensor, stat, default = default_real_tensor)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        deallocate(ltest_real_vector)
        deallocate(ltest_real_tensor)
        deallocate(default_real_vector)
        deallocate(default_real_tensor)
      end if
      if(type == SPUD_INTEGER) then
        if(rank == 0) then
          call get_option(trim(key), ltest_integer_scalar, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", (ltest_integer_scalar - test_integer_scalar) > tol, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_integer_scalar, stat, default = test_integer_scalar + 1)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", ltest_integer_scalar /= test_integer_scalar, .false., "Retrieved incorrect option data")
        else
          call get_option(trim(key), ltest_integer_scalar, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          call get_option(trim(key), ltest_integer_scalar, stat, default = 0)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
        end if
        if(rank == 1) then
          allocate(ltest_integer_vector(shape(1)))
          call get_option(trim(key), ltest_integer_vector, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", count(ltest_integer_vector /= test_integer_vector) > 0, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_integer_vector, stat, default = test_integer_vector + 1)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", count(ltest_integer_vector /= test_integer_vector) > 0, .false., "Retrieved incorrect option data")
          deallocate(ltest_integer_vector)
          allocate(ltest_integer_vector(shape(1) + 1))
          call get_option(trim(key), ltest_integer_vector, stat)
          call report_test("[Shape error when extracting option data]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          allocate(default_integer_vector(shape(1)))
          default_integer_vector = 0
          call get_option(trim(key), ltest_integer_vector, stat, default = default_integer_vector)
          call report_test("[Shape error when extracting option data with default argument]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_integer_vector)
          deallocate(ltest_integer_vector)
        else
          allocate(ltest_integer_vector(3))
          call get_option(trim(key), ltest_integer_vector, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          allocate(default_integer_vector(shape(1)))
          default_integer_vector = 0
          call get_option(trim(key), ltest_integer_vector, stat, default = default_integer_vector)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_integer_vector)
          deallocate(ltest_integer_vector)
        end if
        if(rank == 2) then
          allocate(ltest_integer_tensor(shape(1), shape(2)))
          call get_option(trim(key), ltest_integer_tensor, stat)
          call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data]", count(ltest_integer_tensor /= test_integer_tensor) > 0, .false., "Retrieved incorrect option data")
          call get_option(trim(key), ltest_integer_tensor, stat, default = test_integer_tensor + 1)
          call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
          call report_test("[Extracted correct option data with default argument]", count(ltest_integer_tensor /= test_integer_tensor) > 0, .false., "Retrieved incorrect option data")
          deallocate(ltest_integer_tensor)
          allocate(ltest_integer_tensor(shape(1) + 1, shape(2) + 1))
          call get_option(trim(key), ltest_integer_tensor, stat)
          call report_test("[Shape error when extracting option data]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          allocate(default_integer_tensor(shape(1) + 1, shape(2) + 1))
          default_integer_tensor = 0
          call get_option(trim(key), ltest_integer_tensor, stat, default = default_integer_tensor)
          call report_test("[Shape error when extracting option data with default argument]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_integer_tensor)
          deallocate(ltest_integer_tensor)
        else
          allocate(ltest_integer_tensor(3, 4))
          call get_option(trim(key), ltest_integer_tensor, stat)
          call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
          allocate(default_integer_tensor(shape(1), shape(2)))
          default_integer_tensor = 0
          call get_option(trim(key), ltest_integer_tensor, stat, default = default_integer_tensor)
          call report_test("[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
          deallocate(default_integer_tensor)
          deallocate(ltest_integer_tensor)
        end if        
      else
        allocate(ltest_integer_vector(3))
        allocate(ltest_integer_tensor(3, 4))
        allocate(default_integer_vector(3))      
        default_integer_vector = 0
        allocate(default_integer_tensor(3, 4)) 
        default_integer_tensor = 0
        call get_option(trim(key), ltest_integer_scalar, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_integer_scalar, stat, default = 0)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_integer_vector, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_integer_vector, stat, default = default_integer_vector)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_integer_tensor, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_integer_tensor, stat, default = default_integer_tensor)
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        deallocate(ltest_integer_vector)
        deallocate(ltest_integer_tensor)
        deallocate(default_integer_vector)
        deallocate(default_integer_tensor)
      end if
      if(type == SPUD_CHARACTER) then
        call get_option(trim(key), ltest_char, stat)
        call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
        call report_test("[Extracted correct option data]", ltest_char /= test_char, .false., "Retrieved incorrect option data")
        call get_option(trim(key), ltest_char, stat, default = test_char // " Plus One")
        call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
        call report_test("[Extracted correct option data with default argument]", ltest_char /= test_char, .false., "Retrieved incorrect option data") 
        if(len(test_char) > 0) then
          call get_option(trim(key), short_char, stat)
          call report_test("[Shape error when extracting option data]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
          call get_option(trim(key), short_char, stat, default = "")
          call report_test("[Shape error when extracting option data with default argument]", stat /= SPUD_SHAPE_ERROR, .false., "Returned error code when retrieving option data")
        end if
      else
        call get_option(trim(key), ltest_char, stat)
        call report_test("[Type error when extracting option data]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_char, stat, default = "")
        call report_test("[Type error when extracting option data with default argument]", stat /= SPUD_TYPE_ERROR, .false., "Returned incorrect error code when retrieving option data")
      end if
    end do
    
    call delete_option(trim(key), stat)
    call report_test("[Deleted option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when deleting option")

    call key_error_tests(key)
    
  end subroutine set_and_get_tests
  
  subroutine key_error_tests(key)
    character(len = *), intent(in) :: key
  
    character(len = 255) :: test_char
    integer :: test_integer_scalar
    integer, dimension(:), allocatable :: test_integer_vector, default_integer_vector
    integer, dimension(:, :), allocatable :: test_integer_tensor, default_integer_tensor
    real(D) :: test_real_scalar
    real(D), dimension(:), allocatable :: test_real_vector, default_real_vector
    real(D), dimension(:, :), allocatable :: test_real_tensor, default_real_tensor
    integer :: rank, type, stat
    integer, dimension(2) :: shape
    
    integer :: i, j
  
    call report_test("[Missing option]", have_option(trim(key)), .false., "Missing option reported present")
    type = option_type(trim(key), stat)
    call report_test("[Key error when extracting option type]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    rank = option_rank(trim(key), stat)
    call report_test("[Key error when extracting option rank]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option rank")
    shape = option_shape(trim(key), stat)
    call report_test("[Key error when extracting option shape]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option shape")
    allocate(test_real_vector(3))
    allocate(test_real_tensor(3, 4))
    allocate(test_integer_vector(3))
    allocate(test_integer_tensor(3, 4))
    allocate(default_real_vector(3))
    do i = 1, size(default_real_vector)
      default_real_vector = 42.0_D + i
    end do      
    allocate(default_real_tensor(3, 4))
    do i = 1, size(default_real_tensor, 1)
      do j = 1, size(default_real_tensor, 2)
        default_real_tensor = 42.0_D + i * size(default_real_tensor, 2) + j
      end do
    end do
    allocate(default_integer_vector(3))
    do i = 1, size(default_integer_vector)
      default_integer_vector = 42.0_D + i
    end do 
    allocate(default_integer_tensor(3, 4))
    do i = 1, size(default_real_tensor, 1)
      do j = 1, size(default_integer_tensor, 2)
        default_integer_tensor = 42.0_D + i * size(default_integer_tensor, 2) + j
      end do
    end do
    call get_option(trim(key), test_real_scalar, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_real_scalar, stat, default = 42.0_D)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", abs(test_real_scalar - 42.0) > tol, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_real_vector, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_real_vector, stat, default = default_real_vector)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", maxval(abs(test_real_vector - default_real_vector)) > tol, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_real_tensor, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_real_tensor, stat, default = default_real_tensor)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", maxval(abs(test_real_tensor - default_real_tensor)) > tol, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_integer_scalar, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_integer_scalar, stat, default = 42)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", test_integer_scalar /= 42, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_integer_vector, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_integer_vector, stat, default = default_integer_vector)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", count(test_integer_vector /= default_integer_vector) > 0, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_integer_tensor, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_integer_tensor, stat, default = default_integer_tensor)
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", count(test_integer_tensor /= default_integer_tensor) > 0, .false., "Retrieved incorrect option data")
    call get_option(trim(key), test_char, stat)
    call report_test("[Key error when extracting option data]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    call get_option(trim(key), test_char, stat, default = "Forty Two")
    call report_test("[Extracted option data with default argument]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
    call report_test("[Extracted correct option data (default)]", test_char /= "Forty Two", .false., "Retrieved incorrect option data")
    deallocate(test_real_vector)
    deallocate(test_real_tensor)
    deallocate(test_integer_vector)
    deallocate(test_integer_tensor)
    deallocate(default_real_vector)
    deallocate(default_real_tensor)
    deallocate(default_integer_vector)
    deallocate(default_integer_tensor)
    
  end subroutine key_error_tests

end subroutine test_fspud
