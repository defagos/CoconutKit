//
//  HLSCategoryLinker.h
//  nut
//
//  Created by Cédric Luthi on 7/21/11.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Workaround a linker bug that doesn't link object files containing only Objective-C categories
 * See Technical Q&A QA1490: Building Objective-C static libraries with categories
 * http://developer.apple.com/mac/library/qa/qa2006/qa1490.html
 */
#define HLSLinkCategory(NAME) @interface LINK_##NAME @end @implementation LINK_##NAME @end
