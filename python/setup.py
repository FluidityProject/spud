from os.path import abspath
from setuptools import setup, Extension

setup(name='libspud',
      version='1.1.3',
      description='Python bindings for libspud',
      ext_modules=[Extension('libspud', sources=['libspud.c'],
                             libraries=["spud"],
                             # path to libspud (the actual library, not the c-extension python wrapper 
                             # which will be put in the parent directory by "make libspud.la"
                             # NOTE: For this to work you have to run "python setup.py build" from the
                             # original directory of the current file separately before
                             # running pip install, as pip will build the extension (if it's not built already)
                             # outside of the current context
                             library_dirs=[abspath("..")],
                             # path to spud.h
                             include_dirs=[abspath("../include")])])
