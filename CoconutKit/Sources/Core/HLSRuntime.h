//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * Enable or disable logging of the messages sent through objc_msgSend. Messages are logged to
 *    /tmp/msgSends-XXXX
 * with the following format:
 *    <Receiver object class> <Class which implements the method> <Selector name>
 *
 * Remark:
 * This is a function secretely implemented by the Objective-C runtime, not by CoconutKit. The declaration 
 * is here only provided for convenience
 */
void instrumentObjcMessageSends(BOOL start);

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation
 */
IMP HLSSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation
 */
IMP HLSSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);
