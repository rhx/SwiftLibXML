#!/bin/sh
#
# Wrapper around `swift build' that uses pkg-config in config.sh
# to determine compiler and linker flags
#
Mod=SwiftLibXML
XML_VER=2.2
MAJOR_VER=2.0
if [ -x /usr/bin/xcode-select ]; then
	TOOLCHAIN=`xcode-select -p`/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
	if ! [ -e ${TOOLCHAIN} ]; then
		TOOLCHAIN=`xcode-select -p`/SDKs/MacOSX.sdk
	fi
	LINKFLAGS="-Xlinker -lxml${XML_VER}"
	CCFLAGS="-Xcc -I${TOOLCHAIN}/usr/include -Xcc -I${TOOLCHAIN}/usr/include/libxml2"
else
	export PKG_CONFIG_PATH=`echo /usr/lib/pkgconfig /usr/local/Cellar/libxml2/*/lib/pkgconfig /usr/local/lib/pkgconfig | tr ' ' '\n' | tail -n1`:${PKG_CONFIG_PATH}
	LINKFLAGS="`pkg-config --libs libxml-$MAJOR_VER | tr ' ' '\n' | sed -e 's/^/-Xlinker /' -e 's/-Wl,//' | tr '\n' ' ' | sed -e 's/-Xcc[ 	]*-Xlinker/-Xlinker/g' -e 's/-Xcc *$//' -e 's/-Xlinker *$//'`"
	CCFLAGS="`pkg-config --cflags libxml-$MAJOR_VER | tr ' ' '\n' | sed 's/^/-Xcc /' | tr '\n' ' ' | sed -e 's/-Xcc[ 	]*-Xlinker/-Xlinker/g' -e 's/-Xcc *$//' -e 's/-Xlinker *$//'`"
fi
if [ -z "$@" ]; then
    JAZZY_ARGS="--theme fullwidth --author Ren&eacute;&nbsp;Hexel --author_url https://experts.griffith.edu.au/9237-rene-hexel --github_url https://github.com/rhx/$Mod --github-file-prefix https://github.com/rhx/$Mod/tree/main --root-url http://rhx.github.io/$Mod/ --output docs"
fi
rm -rf .docs.old
mv docs .docs.old 2>/dev/null
[ -e .build/$Mod-doc.json ] || ./build.sh
sourcekitten doc --spm --module-name $Mod -- $CCFLAGS $LINKFLAGS	\
	> .build/$Mod-doc.json
exec jazzy --sourcekitten-sourcefile .build/$Mod-doc.json --clean	\
      --module-version $JAZZY_VER --module $Mod $JAZZY_ARGS "$@"
