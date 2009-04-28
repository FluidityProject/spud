import libspud
libspud.load_options('test.flml')
print libspud.get_option('/problem_type')
libspud.set_option('/problem_type', "helloworld")
print libspud.get_option('/problem_type')

print libspud.get_option('/geometry/dimension')
libspud.set_option('/geometry/dimension', 3)
print libspud.get_option('/geometry/dimension')

print libspud.option_shape('/geometry/dimension')
print libspud.option_shape('/problem_type')

libspud.write_options('test_out.flml')
