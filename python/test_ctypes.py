import libspud
libspud.load_options('test.flml')
print libspud.get_option('/geometry/dimension')
libspud.set_option('/geometry/dimension', 3)
print libspud.get_option('/geometry/dimension')

