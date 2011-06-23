//
//  HLSStripContainerView.m
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripContainerView.h"

@implementation HLSStripContainerView

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize numberOfUnits = m_numberOfUnits;

@synthesize maximumNumberOfStrips = m_maximumNumberOfStrips;

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
