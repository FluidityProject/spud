from distutils.core import setup, Extension

module1 = Extension('libspud',
                    sources = ['libspud.c'], libraries=["spud"], library_dirs=[".."])

setup (name = 'libspud',
       version = '1.1.3',
       description = 'Python bindings for libspud',
       ext_modules = [module1])
