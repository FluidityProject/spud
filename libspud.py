#!/usr/bin/env python

# A draft python binding for libspud

from ctypes import *
import os

libspud = cdll.LoadLibrary(os.getcwd() + '/libspud.so')

cload_options = libspud.cspud_load_options_
cload_options.argtypes = [c_char_p, POINTER(c_int)]
cload_options.restype = None

cget_option_type = libspud.cspud_get_option_type_
cget_option_type.argtypes = [c_char_p, POINTER(c_int), POINTER(c_int)]
cget_option_type.restype = c_int

def load_options(s):
  cload_options(s, byref(c_int(len(s))))

def option_type(s):
  val = c_int()
  out = cget_option_type(s, byref(c_int(len(s))), byref(val))
  return val
