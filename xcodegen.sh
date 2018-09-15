#!/bin/sh
#
# Script to generate an Xcode project using the Swift package manager.
# The generated project gets patched to configure the header search paths
# and pass them to subprojects, based on the configured -I flags.
#
Mod=SwiftLibXML
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
if [ -e /usr/lib/libxml2.2.dylib ]; then
	LINKFLAGS=-lxml2.2
	CCFLAGS='-Xcc -I/usr/include/libxml2 -Xcc -I$(TOOLCHAIN)/usr/include/libxml2'
else
	export PKG_CONFIG_PATH=`echo /usr/local/Cellar/libxml2/*/lib/pkgconfig | tr ' ' '\n' | tail -n1`:${PKG_CONFIG_PATH}
	LINKFLAGS=`pkg-config --libs libxml-2.0 | tr ' ' '\n' | sed 's/^/-Xlinker /' | tr '\n' ' '`
	CCFLAGS=`pkg-config --cflags libxml-2.0 | tr ' ' '\n' | sed 's/^/-Xcc /' | tr '\n' ' ' `
fi
mkdir -p .build
( cd .build								&& \
  cp -p ../Project.xcconfig Project.xcconfig.in				&& \
  echo 'SWIFT_VERSION = 4.1' >> Project.xcconfig.in			&& \
  sed -e 's/ -I ?[^ ]*//g' < Project.xcconfig.in > Project.xcconfig	&& \
  grep 'OTHER_CFLAGS' < Project.xcconfig.in | sed 's/-I */-I/g'		|  \
    tr ' ' '\n' | grep -- -I | tr '\n' ' '				|  \
    sed -e 's/^/HEADER_SEARCH_PATHS = /' -e 's/ -I/ /g' >> Project.xcconfig
)
swift package generate-xcodeproj "$@" # --xcconfig-overrides .build/Project.xcconfig "$@"
( cd ${Mod}.xcodeproj							&& \
  mv project.pbxproj project.pbxproj.in					&& \
  sed < project.pbxproj.in > project.pbxproj				   \
    -e "s|\(HEADER_SEARCH_PATHS = .\)$|\\1 "'"$(inherited)"'" `echo $CCFLAGS | sed -e 's/ *-Xcc  *-I */, /g' | tr ' ' '\n' | sed -e 's/^ */"/' -e 's/ *$/"/' -e 's/"" *//g' -e 's/ *","/,/g' -e 's/,"/",/g' | tr '\n' ' '`,|"						   \
    -e "s|\(OTHER_LDFLAGS = .\)$|\\1 "'"$(inherited)",'" `echo $LINKFLAGS | sed -e 's/ *-l */ -l/g' | tr ' ' '\n' | sed -e 's/^ */"/' -e 's/ *$/"/' -e 's/"" *//g' | tr '\n' ' '`,|"
)
