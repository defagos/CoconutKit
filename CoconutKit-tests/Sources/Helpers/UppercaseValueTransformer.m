//
//  UppercaseValueTransformer.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 06.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "UppercaseValueTransformer.h"

@implementation UppercaseValueTransformer

#pragma mark Overrides

+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    return [value uppercaseString];
}

@end
