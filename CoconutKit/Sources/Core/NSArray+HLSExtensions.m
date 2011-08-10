//
//  NSArray+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "NSArray+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(NSArray_HLSExtensions)

@interface NSArray (HLSExtensionsPrivate)

- (NSArray *)arrayByShiftingNumberOfObjects:(NSUInteger)numberOfElements;

@end

@implementation NSArray (HLSExtensions)

- (id)firstObject
{
    if ([self count] == 0) {
        return nil;
    }
    
    return [self objectAtIndex:0];
}

- (NSArray *)arrayByLeftRotatingNumberOfObjects:(NSUInteger)numberOfObjects
{
    if (numberOfObjects == 0) {
        return self;
    }
    
    NSUInteger shift = numberOfObjects % [self count];
    return [self arrayByShiftingNumberOfObjects:shift];
}

- (NSArray *)arrayByRightRotatingNumberOfObjects:(NSUInteger)numberOfObjects
{
    if (numberOfObjects == 0) {
        return self;
    }
    
    NSUInteger shift = numberOfObjects % [self count];
    return [self arrayByShiftingNumberOfObjects:[self count] - shift];
}

- (NSArray *)arrayByShiftingNumberOfObjects:(NSUInteger)numberOfObjects
{
    return [[self subarrayWithRange:NSMakeRange(numberOfObjects, [self count] -  numberOfObjects)] 
            arrayByAddingObjectsFromArray:[self subarrayWithRange:NSMakeRange(0, numberOfObjects)]];
}

@end

@implementation NSMutableArray (HLSExtensions)

- (void)safelyAddObject:(id)object
{
    if (! object) {
        return;
    }
    [self addObject:object];
}

@end
