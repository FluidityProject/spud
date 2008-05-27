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

  logical :: fail, warn ! logical_scalar_value
  integer :: stat
  real(D) :: value_r_s ! real_scalar_value
  real(D), dimension(2) :: value_r_v ! real vector value
  character(len=2) :: value_s_v ! character vector value

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

end subroutine test_fspud
