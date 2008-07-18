# put this in ~/.diamond/plugins/<SUFFIX>

from diamond.plugins import register_plugin

def plugin_applies(xpath):
  if "/" in xpath:
    return True
  else:
    return False

def handle_click(xml, xpath):
  print "Hello, world!"


register_plugin(plugin_applies, "Test", handle_click)
