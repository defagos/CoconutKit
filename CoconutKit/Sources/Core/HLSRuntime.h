//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * Replace the implementation of a class method, given its selector. Return the original implementation
 */
IMP HLSSwizzleClassSelector(Class clazz, SEL selector, IMP newImplementation);

/**
 * Replace the implementation of an instance method, given its selector. Return the original implementation
 */
IMP HLSSwizzleSelector(Class clazz, SEL selector, IMP newImplementation);
