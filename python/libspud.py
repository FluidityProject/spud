#!/usr/bin/env python

# A draft python binding for libspud
# You will need to compile _libspud.so
# by hand for now -- haven't hooked it up
# to the Makefile

from ctypes import *
import os

SPUD_REAL      = 0
SPUD_INTEGER   = 1
SPUD_NONE      = 2
SPUD_CHARACTER = 3
pytype_map = {SPUD_REAL: float, SPUD_INTEGER: int, SPUD_NONE: None, SPUD_CHARACTER: str}
typepy_map = {float: SPUD_REAL, int: SPUD_INTEGER, None: SPUD_NONE, str: SPUD_CHARACTER}
ctype_map  = {float: c_double, int: c_int, None: None, str: c_char_p}

SPUD_NO_ERROR                = 0
SPUD_KEY_ERROR               = 1
SPUD_TYPE_ERROR              = 2
SPUD_RANK_ERROR              = 3
SPUD_SHAPE_ERROR             = 4
SPUD_NEW_KEY_WARNING         = -1
SPUD_ATTR_SET_FAILED_WARNING = -2

class SpudKeyError(Exception):
  pass

class SpudTypeError(Exception):
  pass

class SpudRankError(Exception):
  pass

class SpudShapeError(Exception):
  pass

spud_exceptions = {SPUD_KEY_ERROR: SpudKeyError,
                   SPUD_TYPE_ERROR: SpudTypeError,
                   SPUD_RANK_ERROR: SpudRankError,
                   SPUD_SHAPE_ERROR: SpudShapeError}

libspud = cdll.LoadLibrary(os.getcwd() + '/_libspud.so')

cload_options = libspud.cspud_load_options_
cload_options.argtypes = [c_char_p, POINTER(c_int)]
cload_options.restype = None

def load_options(s):
  cload_options(s, byref(c_int(len(s))))

cget_option_type = libspud.cspud_get_option_type_
cget_option_type.argtypes = [c_char_p, POINTER(c_int), POINTER(c_int)]
cget_option_type.restype = c_int

def option_type(s):
  val = c_int()
  out = cget_option_type(s, byref(c_int(len(s))), byref(val))

  if out != SPUD_NO_ERROR:
    raise spud_exceptions[out]

  return pytype_map[val.value]

cget_option = libspud.cspud_get_option_
cget_option.argtypes = [c_char_p, POINTER(c_int), c_void_p]
cget_option.restype = c_int

def get_option(s):
  type = option_type(s)
  # assume scalar values for now ..
  if type is str:
    strlen = option_shape(s)[0]
    val = create_string_buffer(strlen+1)
  else:
    val = ctype_map[type]()

  out = cget_option(s, byref(c_int(len(s))), byref(val))
  if out != SPUD_NO_ERROR:
    raise spud_exceptions[out]

  return val.value

cset_option = libspud.cspud_set_option_
cset_option.argtypes = [c_char_p, POINTER(c_int), c_void_p, POINTER(c_int), POINTER(c_int), POINTER(c_int)]
cset_option.restype = c_int

def set_option(s, val):
  py_type = type(val)
  spud_code = typepy_map[py_type]
  c_type = ctype_map[py_type]
  c_val = c_type(val)

  shape_type = c_int * 2
  if py_type is str:
    shape = shape_type(len(val), -1)
    rank = 1
    out = cset_option(s, byref(c_int(len(s))), (c_val), byref(c_int(spud_code)), byref(c_int(rank)), shape)
  else:
    shape = shape_type(1, -1)
    rank = 0
    out = cset_option(s, byref(c_int(len(s))), byref(c_val), byref(c_int(spud_code)), byref(c_int(rank)), shape)

  if out != SPUD_NO_ERROR:
    raise spud_exceptions[out]

coption_shape = libspud.cspud_get_option_shape_
coption_shape.argtypes = [c_char_p, POINTER(c_int), POINTER(c_int)]
coption_shape.restype = int

def option_shape(s):
  shape_type = c_int * 2
  shape = shape_type()
  out = coption_shape(s, byref(c_int(len(s))), shape)

  if out != SPUD_NO_ERROR:
    raise spud_exceptions[out]

  return tuple(shape)

