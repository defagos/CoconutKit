//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * The following methods can be safely used in pure C code (as <objc/runtime.h>)
 */

/**
 * Return the array of all protocols which a class conforms to, including superclasses (unlike
 * protocol_copyMethodDescriptionList which does not take superclasses into account). If the
 * class does not conform to a protocol or is Nil, the function returns NULL
 *
 * The array must be freed by calling free()
 */
Protocol * __unsafe_unretained *hls_class_copyProtocolList(Class cls, unsigned int *pCount);

/**
 * Return YES iff the class or one of its superclasses conforms to the given protocol (unlike
 * class_conformsToProtocol which does not take superclasses into account. Note that this behavior 
 * is currently not documented)
 */
BOOL hls_class_conformsToProtocol(Class cls, Protocol *protocol);

/**
 * Return YES iff the class implements all methods of a given protocol. This function only takes 
 * optional methods into account (required methods must be implemented after all) and takes 
 * into account superclasses as well
 */
BOOL hls_class_implementsProtocol(Class cls, Protocol *protocol);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation,
 * or NULL if not found
 */
IMP HLSSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation,
 * or NULL if not found
 */
IMP HLSSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);
