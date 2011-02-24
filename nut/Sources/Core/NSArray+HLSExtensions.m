//
//  NSArray+HLSExtensions.m
//  nut
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSArray+HLSExtensions.h"

@implementation NSArray (HLSExtensions)

- (id)firstObject
{
    if ([self count] == 0) {
        return nil;
    }
    
    return [self objectAtIndex:0];
}

@end
