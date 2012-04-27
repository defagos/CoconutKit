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
 * Return YES iff the class or one of its superclasses conforms to the given protocol. This
 * is similar to class_conformsToProtocol, but taking superclasses into account. As for 
 * class_conformsToProtocol, conformance is tested strictly, i.e. the protocol must be 
 * explicitly declared in the @interface of the class or of one of its superclasses
 *
 * Remark: The fact that class_conformsToProtocol does not take superclasses into account
 *         is currently not documented
 */
BOOL hls_class_conformsToProtocol(Class cls, Protocol *protocol);

/**
 * Return YES iff the class informally conforms to a protocol, i.e. if it implements all of its
 * required methods (without the need for the protocol to appear in the class @interface). Note 
 * that if a class formally conforms to a protocol it also informally conforms to it
 */
BOOL hls_class_conformsToInformalProtocol(Class cls, Protocol *protocol);

/**
 * Return YES iff the class implements all optional and required methods of a given protocol 
 * (whether the class formally or only informally conforms to the protocol). This method also 
 * takes superclasses into account
 */
BOOL hls_class_implementsProtocol(Class cls, Protocol *protocol);

/**
 * Replace the implementation of a class method, given its selector. Return the original 
 * implementation, or NULL if not found
 */
IMP HLSSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original 
 * implementation, or NULL if not found
 */
IMP HLSSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);
