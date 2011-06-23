//
//  HLSStripContainerView.m
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripContainerView.h"

#import "HLSLogger.h"

#pragma mark -
#pragma mark HLSStrip class interface

@interface HLSStrip : NSObject {
@private
    NSUInteger m_beginPosition;
    NSUInteger m_endPosition;
}

@property (nonatomic, assign) NSUInteger beginPosition;
@property (nonatomic, assign) NSUInteger endPosition;

@end

#pragma mark -
#pragma mark HLSStripContainerView class extension

@interface HLSStripContainerView ()

- (void)initialize;

@end

#pragma mark -
#pragma mark HLSStripContainerView class implementation

@implementation HLSStripContainerView

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    m_subdivisions = NSUIntegerMax;
}

- (void)dealloc
{
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize subdivisions = m_subdivisions;

- (void)setSubdivisions:(NSUInteger)subdivisions
{
    if (m_subdivisionsUsed) {
        HLSLoggerWarn(@"Number of subdivisions cannot be altered anymore");
        return;
    }
    
    m_subdivisionsUsed = subdivisions;
}

@synthesize enabled = m_enabled;

@synthesize delegate = m_delegate;

#pragma mark Strip management

- (BOOL)addStripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition forced:(BOOL)forced
{
    // TODO
    return NO;
}

- (BOOL)addStripAroundPosition:(NSUInteger)position length:(NSUInteger)length forced:(BOOL)forced
{
    // TODO
    return NO;
}

- (BOOL)splitStripAtPosition:(NSUInteger)position
{
    // TODO
    return NO;
}

- (BOOL)deleteStripAtPosition:(NSUInteger)position
{
    // TODO
    return NO;
}

- (BOOL)deleteStripWithIndex:(NSUInteger)index
{
    // TODO
    return NO;
}

@end

#pragma mark -
#pragma mark HLSStrip class implementation

@implementation HLSStrip

#pragma mark Accessors and mutators

@synthesize beginPosition = m_beginPosition;

@synthesize endPosition = m_endPosition;

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
