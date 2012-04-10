//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * Replace the implementation of the origSel class selector of the specified class with the one of the
 * newSel selector of the same class. Return the original implementation
 */
IMP HLSSwizzleClassSelectoR(Class clazz, SEL selector, IMP newImplementation);
IMP HLSSwizzleClassSelector(Class clazz, SEL origSel, SEL newSel);

/**
 * Replace the implementation of the origSel instance selector of the specified class with the one of the
 * newSel selector of the same class. Return the original implementation
 */
IMP HLSSwizzleSelectoR(Class clazz, SEL selector, IMP newImplementation);
IMP HLSSwizzleSelector(Class clazz, SEL origSel, SEL newSel);
