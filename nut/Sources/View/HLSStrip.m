//
//  HLSStrip.m
//  nut
//
//  Created by Samuel Défago on 24.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStrip.h"

@implementation HLSStrip

#pragma mark Class methods

+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition
{
    HLSStrip *strip = [[[[self class] alloc] init] autorelease];
    strip.beginPosition = beginPosition;
    strip.endPosition = endPosition;
    return strip;
}

+ (HLSStrip *)strip
{
    return [[[[self class] alloc] init] autorelease];
}

#pragma mark Accessors and mutators

@synthesize beginPosition = m_beginPosition;

@synthesize endPosition = m_endPosition;

#pragma mark Testing strips

- (BOOL)isOverlappingWithStrip:(HLSStrip *)strip
{
    return self.endPosition > strip.beginPosition && strip.endPosition > self.beginPosition;
}

- (BOOL)isContainedInStrip:(HLSStrip *)strip
{
    return strip.beginPosition <= self.beginPosition && self.endPosition <= strip.endPosition;
}

- (BOOL)containsPosition:(NSUInteger)position
{
    return self.beginPosition <= position && position <= self.endPosition;
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; beginPosition: %d; endPosition: %d>", 
            [self class],
            self,
            self.beginPosition,
            self.endPosition];
}

@end
