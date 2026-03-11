//
//  libxml2-import.h
//  CLibXML2
//
//  Created by Rene Hexel on 24/03/2016.
//  Copyright © 2016, 2021 Rene Hexel. All rights reserved.
//

#ifndef libxml2_import_h
#define libxml2_import_h

// Support both layout styles:
//   <libxml2/libxml/…>  — macOS/Linux with parent dir in include path
//   <libxml/…>          — when pkg-config adds the libxml2/ dir itself (e.g. MSYS2)
#if __has_include(<libxml2/libxml/xmlreader.h>)
#  include <libxml2/libxml/xmlreader.h>
#  include <libxml2/libxml/parser.h>
#  include <libxml2/libxml/xpath.h>
#  include <libxml2/libxml/xpathInternals.h>
#  include <libxml2/libxml/HTMLparser.h>
#else
#  include <libxml/xmlreader.h>
#  include <libxml/parser.h>
#  include <libxml/xpath.h>
#  include <libxml/xpathInternals.h>
#  include <libxml/HTMLparser.h>
#endif

#endif /* libxml2_import_h */
