//
//  HLSRuntime.h
//  CoconutKit
//
//  Created by Samuel Défago on 30.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import <objc/runtime.h> 

/**
 * Replace the implementation of the origSel selector of the specified class with the one of the
 * newSel selector of the same class. Return the original implementation
 */
IMP HLSSwizzleSelector(Class clazz, SEL origSel, SEL newSel);
