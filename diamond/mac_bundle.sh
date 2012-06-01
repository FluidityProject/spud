#!/bin/bash
#
# Package script for Gaphor.
#
# Thanks: http://stackoverflow.com/questions/1596945/building-osx-app-bundle

# Also fix $INSTALLDIR/MacOS/diamond in case this number changes
PYVER=2.7
APP=Diamond.app
INSTALLDIR=$APP/Contents
LIBDIR=$INSTALLDIR/lib

LOCALDIR=/opt/gtk/

# set up our virtual python environment
virtualenv --python=python$PYVER --no-site-packages $INSTALLDIR

# install diamond in it
$INSTALLDIR/bin/python setup.py install

# install dxdiff
cd ../dxdiff;
../diamond/$INSTALLDIR/bin/python setup.py install

cd ../diamond;

# This has placed a bin/diamond file which just launches our bin/diamond
# Unfortunately, it's in the wrong place, so move it 
mkdir $INSTALLDIR/MacOS
cp $INSTALLDIR/bin/diamond $INSTALLDIR/MacOS/


# Sort out the MacResources
cp MacOS_Resources/* $INSTALLDIR/
mkdir $INSTALLDIR/Resources
mv $INSTALLDIR/diamond.icns $INSTALLDIR/Resources/

# Now we have to play silly buggers with some bits of the diamond file
# as the Mac app packages adds a command line argument, which we want to ignore
sed -i -e 's/sys.argv\[1:\]/sys.argv\[2:\]/' $INSTALLDIR/lib/python2.7/site-packages/diamond-1.0-py2.7.egg/EGG-INFO/scripts/diamond

# Now we have to feed the app some schemas or it's all for nothing
# Set up the schema folders
mkdir -p $INSTALLDIR/share/schemata

# Let's get the latest fluidity release schema
# NOTE: UPDATE URL AFTER A RELEASE
if [ ! -d fluidity ]; then
	bzr branch lp:fluidity/4.1 fluidity
else
	cd fluidity
	bzr up
	cd ../
fi
# Make the schemata description
# The path of the RNG is relative to diamond.egg/EGG_INFO directory
cat > $INSTALLDIR/share/schemata/flml << EOF
Fluidity Markup Language
../../../../../share/schemata/fluidity/fluidity_options.rng
EOF
rm -rf $INSTALLDIR/share/schemata/fluidity
mkdir $INSTALLDIR/share/schemata/fluidity
cp fluidity/schemas/*.rng $INSTALLDIR/share/schemata/fluidity/
cp ../schema/*.rng $INSTALLDIR/share/schemata/fluidity/
# clean up
#rm -rf fluidity

# Do the above for any other schema we want to distribute
# Don't forget the spud-base!



# Let's get lxml installed
$INSTALLDIR/bin/easy_install --allow-hosts=lxml.de,*.python.org lxml

# Temp. solution - Just manually copy stuff we know we need
SITEPACKAGES=$LIBDIR/python$PYVER/site-packages

mkdir -p $SITEPACKAGES

# This locates pygtk.pyc. We want the source file
pygtk=`python -c "import pygtk; print pygtk.__file__[:-1]"`
oldsite=`dirname $pygtk`
gobject=`python -c "import gobject; print gobject.__file__[:-1]"`
glib=`python -c "import glib; print glib.__file__[:-1]"`

# Copy PyGtk and related libraries
cp $pygtk $SITEPACKAGES
cp -r `dirname $gobject` $SITEPACKAGES
cp -r `dirname $glib` $SITEPACKAGES
cp -r $oldsite/cairo $SITEPACKAGES
cp -r $oldsite/gtk-2.0 $SITEPACKAGES
cp $oldsite/pygtk.pth $SITEPACKAGES


# Modules, config, etc.
for dir in etc/pango lib/pango etc/gtk-2.0 lib/gtk-2.0 share/themes lib/gdk-pixbuf-2.0; do
  mkdir -p $INSTALLDIR/$dir
  cp -r $LOCALDIR/$dir/* $INSTALLDIR/$dir
done

# Resources, are processed on startup
for dir in etc/gtk-2.0 etc/pango lib/gdk-pixbuf-2.0/2.10.0; do
  mkdir -p $INSTALLDIR/Resources/$dir
  cp $LOCALDIR/$dir/* $INSTALLDIR/Resources/$dir
done

# Somehow files are writen with mode 444
find $INSTALLDIR -type f -exec chmod u+w {} \;

function log() {
  echo $* >&2
}

function resolve_deps() {
  local lib=$1
  local dep
  otool -L $lib | grep -e "^.$LOCALDIR/" |\
      while read dep _; do
    echo $dep
  done
}

function fix_paths() {
  local lib=$1
  log Fixing $lib
  for dep in `resolve_deps $lib`; do
    #log Fixing `basename $lib`
    log "|  $dep"
    install_name_tool -change $dep @executable_path/../lib/`basename $dep` $lib
  done
}

binlibs=`find $INSTALLDIR -type f -name '*.so'`

for lib in $binlibs; do
  log Resolving $lib
  resolve_deps $lib
  fix_paths $lib
done | sort -u | while read lib; do
  log Copying $lib
  cp $lib $LIBDIR
  chmod u+w $LIBDIR/`basename $lib`
  fix_paths $LIBDIR/`basename $lib`
done

function fix_config() {
  local file=$1
  local replace=$2

  mv $file $file.orig
  sed "$replace" $file.orig > $file
}

# Fix config files
fix_config $INSTALLDIR/Resources/etc/pango/pango.modules 's#/usr/local/.*lib/#/usr/local/lib/#'
fix_config $INSTALLDIR/Resources/etc/gtk-2.0/gtk.immodules 's#/usr/local/.*lib/#/usr/local/lib/#'
fix_config $INSTALLDIR/Resources/lib/gdk-pixbuf-2.0/2.10.0/loaders.cache 's#/usr/local/.*lib/#/usr/local/lib/#'

# Package!

VERSION=0.01
zip -rq Diamond-$VERSION-osx-x11.zip $APP
hdiutil create -srcfolder $APP Diamond-$VERSION-x11.dmg
