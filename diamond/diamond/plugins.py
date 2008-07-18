import os
import os.path
import sys

plugins = []

class PluginDetails(object):
  def __init__(self, applies, name, cb):
    self.applies = applies
    self.name = name
    self.cb = cb

  def matches(self, xpath):
    return self.applies(xpath)

  def execute(self, xml, xpath):
    self.cb(xml, xpath)

def register_plugin(applies, name, cb):
  global plugins
  p = PluginDetails(applies, name, cb)
  plugins.append(p)

def configure_plugins(suffix):
  homedir = os.path.expanduser('~')
  dirs = [os.path.join(homedir, ".diamond", "plugins", suffix)]
  if sys.platform != "win32" and sys.platform != "win64":
    dirs.append("/etc/diamond/plugins/" + suffix)

  for dir in dirs:
    sys.path.insert(0, dir)
    try:
      for file in os.listdir(dir):
        module_name, ext = os.path.splitext(file)
        if ext == ".py":
          module = __import__(module_name)
    except OSError:
      pass
