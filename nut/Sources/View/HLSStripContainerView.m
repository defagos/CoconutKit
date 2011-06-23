//
//  HLSStripContainerView.m
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripContainerView.h"

#import "HLSLogger.h"

// TODO: Set m_positionsUsed to YES somewhere!!!!

#pragma mark -
#pragma mark HLSStrip class interface

/**
 * Lightweight object representing a strip in the container view
 */
@interface HLSStrip : NSObject {
@private
    NSUInteger m_beginPosition;
    NSUInteger m_endPosition;
}

+ (HLSStrip *)stripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;
+ (HLSStrip *)strip;

@property (nonatomic, assign) NSUInteger beginPosition;
@property (nonatomic, assign) NSUInteger endPosition;

- (BOOL)isOverlappingWithStrip:(HLSStrip *)strip;
- (BOOL)isContainedInStrip:(HLSStrip *)strip;

- (BOOL)containsPosition:(NSUInteger)position;

@end

#pragma mark -
#pragma mark HLSStripContainerView class extension

@interface HLSStripContainerView ()

- (void)initialize;

@property (nonatomic, retain) NSArray *strips;

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
    self.positions = NSUIntegerMax;
    self.strips = [NSMutableArray array];
}

- (void)dealloc
{
    self.strips = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize strips = m_strips;

@synthesize positions = m_positions;

- (void)setPositions:(NSUInteger)positions
{
    if (m_positionsUsed) {
        HLSLoggerWarn(@"Number of positions cannot be altered anymore");
        return;
    }
    
    m_positions = positions;
}

@synthesize enabled = m_enabled;

@synthesize delegate = m_delegate;

#pragma mark Strip management

- (BOOL)addStripAtPosition:(NSUInteger)position length:(NSUInteger)length
{    
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return NO;
    }
    
    if (length == 0) {
        HLSLoggerError(@"Length cannot be 0");
        return NO;
    }
    
    if (length >= self.positions) {
        HLSLoggerWarn(@"Default length must not exceed number of available positions");
        return NO;
    }
    
    // Find an insertion point
    NSUInteger previousEndPosition = 0;
    NSUInteger nextBeginPosition = self.positions - 1;
    NSUInteger index = 0;
    HLSStrip *newStrip = nil;
    for (HLSStrip *strip in self.strips) {
        if ([strip containsPosition:position]) {
            HLSLoggerInfo(@"A strip already exists at the given position");
            return NO;
        }
        
        // Insertion point found
        if (strip.beginPosition > position) {
            nextBeginPosition = strip.beginPosition;
            break;
        }
        
        previousEndPosition = strip.endPosition;
        
        ++index;
    }
    
    // No strip after insertion point
    if (index == [self.strips count]) {
        nextBeginPosition = self.positions - 1;
    }
    
    // Arrived here, we know that space for insertion is available in [previousEndPosition; nextBeginPosition]
    
    // If not enough space, fill it completely
    if (length >= nextBeginPosition - previousEndPosition) {
        newStrip = [HLSStrip stripWithBeginPosition:previousEndPosition endPosition:nextBeginPosition];
    }
    // Try to center around position if possible, otherwise center as close as possible to position so that there
    // is no overlap with forbidden left / right regions
    else {
        // Fix position if needed
        NSUInteger minPosition = previousEndPosition + (NSUInteger)floorf(length / 2.f);
        NSUInteger maxPosition = nextBeginPosition - (NSUInteger)ceilf(length / 2.f);
        if (position < minPosition) {
            position = minPosition;
        }
        else if (position > maxPosition) {
            position = maxPosition;
        }
        
        // Create the new strip, centered at position
        newStrip = [HLSStrip stripWithBeginPosition:position - (NSUInteger)floorf(length / 2.f)
                                        endPosition:position + (NSUInteger)ceilf(length / 2.f)];
    }
    
    // Insert the new strip in the correct order so that the array is sorted by beginPosition
    NSMutableArray *strips = [NSMutableArray arrayWithArray:self.strips];
    if (index == [self.strips count]) {
        [strips addObject:newStrip];
    }
    else {
        [strips insertObject:newStrip atIndex:index];
    }
    self.strips = [NSArray arrayWithArray:strips];
    return YES;
}

- (BOOL)splitStripAtPosition:(NSUInteger)position
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return NO;
    }    
    
    BOOL split = NO;
    NSMutableArray *stripsModified = [NSMutableArray array];
    for (HLSStrip *strip in self.strips) {
        if ([strip containsPosition:position] && position != strip.beginPosition && position != strip.endPosition) {
            HLSStrip *subStrip1 = [HLSStrip stripWithBeginPosition:strip.beginPosition endPosition:position];
            [stripsModified addObject:subStrip1];
            HLSStrip *subStrip2 = [HLSStrip stripWithBeginPosition:position endPosition:strip.endPosition];
            [stripsModified addObject:subStrip2];
            split = YES;
        }
        else {
            [stripsModified addObject:strip];
        }
    }
    self.strips = [NSArray arrayWithArray:stripsModified];
    return split;
}

- (BOOL)deleteStripsAtPosition:(NSUInteger)position
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return NO;
    }
    
    BOOL deleted = NO;
    NSMutableArray *stripsCleaned = [NSMutableArray array];
    for (HLSStrip *strip in self.strips) {
        if (! [strip containsPosition:position]) {
            [stripsCleaned addObject:strip];
        }
        else {
            deleted = YES;
        }
    }
    self.strips = [NSArray arrayWithArray:stripsCleaned];
    return deleted;
}

- (BOOL)deleteStripWithIndex:(NSUInteger)index
{
    if (index >= [self.strips count]) {
        HLSLoggerWarn(@"Incorrect index");
        return NO;
    }
    
    NSMutableArray *stripsCopy = [NSMutableArray arrayWithArray:self.strips];
    [stripsCopy removeObjectAtIndex:index];
    self.strips = [NSArray arrayWithArray:stripsCopy];
    return YES;
}

@end

#pragma mark -
#pragma mark HLSStrip class implementation

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
