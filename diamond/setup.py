from distutils.core import setup
from distutils.extension import Extension

setup(
      name='diamond',
      version='0.1b',
      description="Fluidity preprocessor",
      author = "The ICOM team",
      author_email = "patrick.farrell@imperial.ac.uk",
      url = "http://amcg.ese.ic.ac.uk",
      py_modules=["schema", "tree", "interface", "TextBufferMarkup", "dialogs", "debug", "config"],
      scripts=["diamond"],
      data_files = [("/usr/share/diamond/gui", ["gui/gui.glade", "gui/diamond.svg"])],
     )

