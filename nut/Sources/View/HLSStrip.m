//
//  HLSStrip.m
//  nut
//
//  Created by Samuel Défago on 24.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStrip.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@interface HLSStrip ()

@property (nonatomic, assign) NSUInteger beginPosition;
@property (nonatomic, assign) NSUInteger endPosition;

@end

@implementation HLSStrip

#pragma mark Class methods

+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition
{
    HLSStrip *strip = [[[[self class] alloc] initWithBeginPosition:beginPosition endPosition:endPosition] autorelease];
    return strip;
}

#pragma mark Object creation and destruction

- (id)initWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition
{
    if ((self = [super init])) {
        // Check input
        if (endPosition <= beginPosition) {
            HLSLoggerError(@"End position must be larger than begin position");
            [self release];
            return nil;
        }
        
        self.beginPosition = beginPosition;
        self.endPosition = endPosition;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

- (void)dealloc
{
    self.tag = nil;
    self.userInfo = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize beginPosition = m_beginPosition;

@synthesize endPosition = m_endPosition;

@synthesize tag = m_tag;

@synthesize userInfo = m_userInfo;

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
    return [NSString stringWithFormat:@"<%@: %p; beginPosition: %d; endPosition: %d; tag: %@>", 
            [self class],
            self,
            self.beginPosition,
            self.endPosition,
            self.tag];
}

@end
