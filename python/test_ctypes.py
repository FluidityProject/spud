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

print libspud.option_rank('/geometry/dimension')
print libspud.option_rank('/physical_parameters/gravity/vector_field::GravityDirection/prescribed/value/constant')

libspud.write_options('test_out.flml')
