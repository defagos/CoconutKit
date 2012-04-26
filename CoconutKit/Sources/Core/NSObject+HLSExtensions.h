//
//  NSObject+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSObject (HLSExtensions)

/**
 * Returns the name of a class as a string
 */
+ (NSString *)className;

/**
 * Returns the official name of an object's class (i.e. as returned by [self class]) as a string. May be faked by 
 * dynamic subclasses (e.g. those added by KVO)
 */
- (NSString *)className;

@end
