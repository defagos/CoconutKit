//
//  HLSObjectAnimation.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSObjectAnimation.h"

#import "HLSObjectAnimation+Friend.h"

@implementation HLSObjectAnimation

#pragma mark Class methods

+ (instancetype)animation
{
    return [[[self class] alloc] init];
}

#pragma mark NSCopying protocol implementation

- (id)copyWithZone:(NSZone *)zone
{
    return [[[self class] allocWithZone:zone] init];
}

#pragma mark Reverse animation

- (id)reverseObjectAnimation
{
    return [[self class] animation];
}

@end
