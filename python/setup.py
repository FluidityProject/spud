from distutils.core import setup, Extension
import os.path

module1 = Extension('libspud', sources = ['libspud.c'], libraries=["spud"], library_dirs=[os.path.abspath("..")])

setup (name = 'libspud',
       version = '1.1.3',
       description = 'Python bindings for libspud',
       ext_modules = [module1])
