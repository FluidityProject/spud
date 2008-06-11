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
    
  call set_tests("/real_scalar_value", test_real_scalar = 42.0_D)
  call set_tests("/real_vector_value", test_real_vector = (/42.0_D, 43.0_D/))
  call set_tests("/real_tensor_value", test_real_tensor = reshape((/42.0_D, 43.0_D, 44.0_D, 45.0_D, 46.0_D, 47.0_D/), (/2, 3/)))
  
  ! Pre-existing tests
  call tests_old
  
contains

  
  subroutine set_tests(key, test_char, test_integer_scalar, test_integer_vector, test_integer_tensor, test_real_scalar, test_real_vector, test_real_tensor)
    character(len = *), intent(in) :: key
    character(len = *), optional, intent(in) :: test_char
    integer, optional, intent(in) :: test_integer_scalar
    integer, dimension(:), optional, intent(in) :: test_integer_vector
    integer, dimension(:, :), optional, intent(in) :: test_integer_tensor
    real(D), optional, intent(in) :: test_real_scalar
    real(D), dimension(:), optional, intent(in) :: test_real_vector
    real(D), dimension(:, :), optional, intent(in) :: test_real_tensor
    
    integer :: type, rank
    integer, dimension(2) :: shape
    
    character(len = 255) :: ltest_char
    integer :: ltest_integer_scalar
    integer, dimension(:), allocatable :: ltest_integer_vector
    integer, dimension(:, :), allocatable :: ltest_integer_tensor
    real(D) :: ltest_real_scalar
    real(D), dimension(:), allocatable :: ltest_real_vector, default_real_vector
    real(D), dimension(:, :), allocatable :: ltest_real_tensor, default_real_tensor
    integer :: lrank, ltype, stat
    integer, dimension(2) :: lshape
    
    if(present(test_integer_scalar)) then
      type = SPUD_INTEGER
      rank = 0
      shape = (/-1, -1/)
    else if(present(test_integer_vector)) then
      type = SPUD_INTEGER
      rank = 1
      shape = (/size(test_integer_vector), -1/)
    else if(present(test_integer_tensor)) then
      type = SPUD_INTEGER
      rank = 2
      shape = (/size(test_integer_tensor, 1), size(test_integer_tensor, 2)/)
    else if(present(test_real_scalar)) then
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
    else if(present(test_char)) then
      type = SPUD_CHARACTER
      rank = 0
      shape = (/-1, -1/)
    else
      type = SPUD_NONE
      rank = -1
      shape = (/-1, -1/)
    end if
    
    call report_test("[Option missing]", have_option(trim(key)), .false., "Missing option reported present")
    
    if(present(test_integer_scalar)) then
    else if(present(test_integer_vector)) then
    else if(present(test_integer_tensor)) then
    else if(present(test_real_scalar)) then
      call set_option(trim(key), test_real_scalar, stat)
      call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
      call set_option(trim(key), test_real_scalar, stat)
      call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
    else if(present(test_real_vector)) then
      call set_option(trim(key), test_real_vector, stat)
      call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
      call set_option(trim(key), test_real_vector, stat)
      call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
    else if(present(test_real_tensor)) then
      call set_option(trim(key), test_real_tensor, stat)
      call report_test("[New option]", stat /= SPUD_NEW_KEY_WARNING, .false., "Failed to return new key warning when setting option")
      call set_option(trim(key), test_real_tensor, stat)
      call report_test("[Set existing option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when setting option")
    else if(present(test_char)) then
    else
    end if
    
    call report_test("[Option present]", .not. have_option(trim(key)), .false., "Present option reported missing")
    ltype = option_type(trim(key), stat)
    call report_test("[Extracted option type]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option type")
    call report_test("[Option type]", ltype /= type, .false., "Incorrect option type returned")
    lrank = option_rank(trim(key), stat)
    call report_test("[Extracted option rank]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option rank")
    call report_test("[Option rank]", lrank /= rank, .false., "Incorrect option rank returned")
    lshape = option_shape(trim(key), stat)
    call report_test("[Extracted option shape]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option shape")
    call report_test("[Option shape]", count(lshape /= shape) /= 0, .false., "Incorrect option shape returned")
   
    if(type == SPUD_REAL) then
      if(rank == 0) then
        call get_option(trim(key), ltest_real_scalar, stat)
        call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
        call report_test("[Extracted correct option data]", (ltest_real_scalar - test_real_scalar) > tol, .false., "Retrieved incorrect option data")
      else
        call get_option(trim(key), ltest_real_scalar, stat)
        call report_test("[Rank error when extracting option data]", stat /= SPUD_RANK_ERROR, .false., "Returned incorrect error code when retrieving option data")
        call get_option(trim(key), ltest_real_scalar, stat, default = 0.0_D)
        call report_test("[[Rank error when extracting option data with default argument]", stat /= SPUD_RANK_ERROR, .false., "Returned error code when retrieving option data")
      end if
      if(rank == 1) then
        allocate(ltest_real_vector(shape(1)))
        call get_option(trim(key), ltest_real_vector, stat)
        call report_test("[Extracted option data]", stat /= SPUD_NO_ERROR, .false., "Returned error code when retrieving option data")
        call report_test("[Extracted correct option data]", maxval(abs(ltest_real_vector - test_real_vector)) > tol, .false., "Retrieved incorrect option data")
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
    
    call delete_option(trim(key), stat)
    call report_test("[Deleted option]", stat /= SPUD_NO_ERROR, .false., "Returned error code when deleting option")
    
    call report_test("[Missing option]", have_option(trim(key)), .false., "Missing option reported present")
    type = option_type(trim(key), stat)
    call report_test("[Key error when extracting option type]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option type")
    rank = option_rank(trim(key), stat)
    call report_test("[Key error when extracting option rank]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option rank")
    shape = option_shape(trim(key), stat)
    call report_test("[Key error when extracting option shape]", stat /= SPUD_KEY_ERROR, .false., "Returned incorrect error code when retrieving option shape")

  end subroutine set_tests

  subroutine tests_old()

    logical :: fail, warn ! logical_scalar_value
    integer :: stat
    real(D) :: value_r_s ! real_scalar_value
    real(D), dimension(2) :: value_r_v ! real vector value
    character(len=2) :: value_s_v ! character vector value

    print *, "*** PREVIOUS TESTS ***"

    warn=.false.

    fail = have_option("theta_r_s")
    call report_test("[missing option]", fail, warn, "Missing option reported present.")

    call set_option("theta_r_s", 1.0_D, stat)
    fail = (stat /= SPUD_NEW_KEY_WARNING)
    call report_test("[new option]", fail, warn, "New option should return a warning.")

    fail = .not. have_option("theta_r_s")
    call report_test("[present option]", fail, warn, "Present option reported missing.")

    fail = (option_type("theta_r_s") /= SPUD_REAL)
    call report_test("[option type]", fail, warn, "Retrieved option not real.")

    fail = (option_rank("theta_r_s") /= 0)
    call report_test("[option rank]", fail, warn, "Retrieved option rank not 0.")

    call get_option("theta_r_s", value_r_s)
    fail = (value_r_s /= 1.0_D)
    call report_test("[option value_r_s]", fail, warn, "Retrieved option value_r_s not 1.0.")

    call set_option("theta_r_s", 2.0_D, stat)
    fail = (stat == SPUD_NEW_KEY_WARNING)
    call report_test("[existing option]", fail, warn, "Setting existing option should not return a warning.")

    call get_option("theta_r_s", value_r_s)
    fail = (value_r_s /= 2.0_D)
    call report_test("[updated value_r_s]", fail, warn, "Overwritten option value_r_s not 2.0.")

    fail = have_option("theta_r_v")
    call report_test("[missing option]", fail, warn, "Missing option reported present.")

    call set_option("theta_r_v", (/1.0_D, 2.0_D/), stat)
    fail = (stat /= SPUD_NEW_KEY_WARNING)
    call report_test("[new option]", fail, warn, "New option should return a warning.")

    fail = .not. have_option("theta_r_v")
    call report_test("[present option]", fail, warn, "Present option reported missing.")

    fail = (option_type("theta_r_v") /= SPUD_REAL)
    call report_test("[option type]", fail, warn, "Retrieved option not real.")

    fail = (option_rank("theta_r_v") /= 1)
    call report_test("[option rank]", fail, warn, "Retrieved option rank not 1.")

    call get_option("theta_r_v", value_r_v)
    fail = (value_r_v(1) /= 1.0_D .or. value_r_v(2) /= 2.0_D)
    call report_test("[option value_r_v]", fail, warn, "Retrieved option value_r_v not correct.")

    fail = have_option("theta_s_v")
    call report_test("[missing option]", fail, warn, "Missing option reported present.")

    call set_option("theta_s_v", "ab", stat)
    fail = (stat /= SPUD_NEW_KEY_WARNING)
    call report_test("[new option]", fail, warn, "New option should return a warning.")

    fail = .not. have_option("theta_s_v")
    call report_test("[present option]", fail, warn, "Present option reported missing.")

    fail = (option_type("theta_s_v") /= SPUD_CHARACTER)
    call report_test("[option type]", fail, warn, "Retrieved option not real.")

    fail = (option_rank("theta_s_v") /= 1)
    call report_test("[option rank]", fail, warn, "Retrieved option rank not 1.")

    call get_option("theta_s_v", value_s_v)
    fail = (value_s_v /= "ab")
    call report_test("[option value_s_v]", fail, warn, "Retrieved option value_s_v not correct.")

  end subroutine tests_old

end subroutine test_fspud
