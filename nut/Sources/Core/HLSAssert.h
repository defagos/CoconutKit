//
//  HLSAssert.h
//  nut
//
//  Created by Samuel Défago on 9/19/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Assertion at compile time
 *
 * Remark: Using a typedef avoids "unused variable" warnings, and enclosing within a block avoids "type redefinition" errors
 */
#define HLS_STATIC_ASSERT(expr)         {typedef char static_assertion_failure[(expr) ? 1 : -1];}
