subroutine test_options_dict

  use options
  use unittest_tools
  implicit none

  logical :: fail, warn, value_l_s ! logical_scalar_value
  integer :: stat
  real :: value_r_s ! real_scalar_value
  real, dimension(2) :: value_r_v ! real vector value
  character(len=2) :: value_s_v ! character vector value
 
  warn=.false.

  fail = have_option("theta_r_s")
  call report_test("[missing option]", fail, warn, "Missing option reported present.")
  
  call set_option("theta_r_s", 1.0, stat)
  fail = (stat /= OPT_NEW_KEY_WARNING)
  call report_test("[new option]", fail, warn, "New option should return a warning.")
  
  fail = .not. have_option("theta_r_s")
  call report_test("[present option]", fail, warn, "Present option reported missing.")

  fail = (option_type("theta_r_s") /= OPT_REAL)
  call report_test("[option type]", fail, warn, "Retrieved option not real.")

  fail = (option_rank("theta_r_s") /= 0)
  call report_test("[option rank]", fail, warn, "Retrieved option rank not 0.")

  call get_option("theta_r_s", value_r_s)
  fail = (value_r_s /= 1.0)
  call report_test("[option value_r_s]", fail, warn, "Retrieved option value_r_s not 1.0.")

  call set_option("theta_r_s", 2.0, stat)
  fail = (stat == OPT_NEW_KEY_WARNING)
  call report_test("[existing option]", fail, warn, "Setting existing option should not return a warning.")
  
  call get_option("theta_r_s", value_r_s)
  fail = (value_r_s /= 2.0)
  call report_test("[updated value_r_s]", fail, warn, "Overwritten option value_r_s not 2.0.")
    
  fail = have_option("theta_l_s")
  call report_test("[missing option]", fail, warn, "Missing option reported present.")
  
  call set_option("theta_l_s", .true., stat)
  fail = (stat /= OPT_NEW_KEY_WARNING)
  call report_test("[new option]", fail, warn, "New option should return a warning.")
  
  fail = .not. have_option("theta_l_s")
  call report_test("[present option]", fail, warn, "Present option reported missing.")

  fail = (option_type("theta_l_s") /= OPT_LOGICAL)
  call report_test("[option type]", fail, warn, "Retrieved option not real.")

  fail = (option_rank("theta_l_s") /= 0)
  call report_test("[option rank]", fail, warn, "Retrieved option rank not 0.")

  !call get_option("theta_l_s", value_l_s)
  !fail = (value_l_s .eqv. .false.)
  !call report_test("[option value_l_s]", fail, warn, "Retrieved option value_l_s not .true..")

  fail = have_option("theta_r_v")
  call report_test("[missing option]", fail, warn, "Missing option reported present.")
  
  call set_option("theta_r_v", (/1.0, 2.0/), stat)
  fail = (stat /= OPT_NEW_KEY_WARNING)
  call report_test("[new option]", fail, warn, "New option should return a warning.")
  
  fail = .not. have_option("theta_r_v")
  call report_test("[present option]", fail, warn, "Present option reported missing.")

  fail = (option_type("theta_r_v") /= OPT_REAL)
  call report_test("[option type]", fail, warn, "Retrieved option not real.")

  fail = (option_rank("theta_r_v") /= 1)
  call report_test("[option rank]", fail, warn, "Retrieved option rank not 0.")

  call get_option("theta_r_v", value_r_v)
  fail = (value_r_v(1) /= 1.0 .or. value_r_v(2) /= 2.0)
  call report_test("[option value_r_v]", fail, warn, "Retrieved option value_r_v not correct.")

  fail = have_option("theta_s_v")
  call report_test("[missing option]", fail, warn, "Missing option reported present.")
  
  call set_option("theta_s_v", "ab", stat)
  fail = (stat /= OPT_NEW_KEY_WARNING)
  call report_test("[new option]", fail, warn, "New option should return a warning.")
  
  fail = .not. have_option("theta_s_v")
  call report_test("[present option]", fail, warn, "Present option reported missing.")

  fail = (option_type("theta_s_v") /= OPT_CHARACTER)
  call report_test("[option type]", fail, warn, "Retrieved option not real.")

  fail = (option_rank("theta_s_v") /= 1)
  call report_test("[option rank]", fail, warn, "Retrieved option rank not 0.")

  call get_option("theta_s_v", value_s_v)
  fail = (value_s_v /= "ab")
  call report_test("[option value_s_v]", fail, warn, "Retrieved option value_s_v not correct.")
end subroutine test_options_dict
