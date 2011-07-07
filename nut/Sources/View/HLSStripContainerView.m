//
//  HLSStripContainerView.m
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStripContainerView.h"

#import "HLSAnimation.h"
#import "HLSAssert.h"
#import "HLSLogger.h"
#import "HLSStripView.h"

static NSString *kAddStripAnimationTag = @"addStrip";
static NSString *kRemoveStripAnimationTag = @"removeStrip";

// TODO: Set m_positionsUsed to YES somewhere!!!! Implement disabled mode

@interface HLSStripContainerView () <HLSAnimationDelegate, HLSStripViewDelegate>

- (void)initialize;

@property (nonatomic, retain) NSArray *allStrips;
@property (nonatomic, retain) NSMutableDictionary *stripToViewMap;

- (CGFloat)xPosForPosition:(NSUInteger)position;
- (NSUInteger)lowerPositionForXPos:(CGFloat)xPos;
- (CGRect)frameForStrip:(HLSStrip *)strip;

- (HLSStripView *)addViewForStrip:(HLSStrip *)strip;
- (HLSStripView *)buildStripViewForStrip:(HLSStrip *)strip;
- (void)removeViewForStrip:(HLSStrip *)strip;
- (HLSStripView *)viewForStrip:(HLSStrip *)strip;

- (HLSAnimation *)animationAddingStrip:(HLSStrip *)strip;
- (HLSAnimation *)animationRemovingStrip:(HLSStrip *)strip;

@end

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
    self.allStrips = [NSMutableArray array];
    self.stripToViewMap = [NSMutableDictionary dictionary];
}

- (void)dealloc
{
    self.allStrips = nil;
    self.stripToViewMap = nil;
    self.delegate = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize allStrips = m_allStrips;

- (NSArray *)strips
{
    return self.allStrips;
}

- (void)setStrips:(NSArray *)strips
{
    HLSAssertObjectsInEnumerationAreMembersOfClass(strips, HLSStrip);
    
    // Order and remove bad and overlapping strips
    NSSortDescriptor *beginDateSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"beginPosition" ascending:YES];
    NSArray *sortedStrips = [strips sortedArrayUsingDescriptors:[NSArray arrayWithObject:beginDateSortDescriptor]];
    NSMutableArray *cleanedStrips = [NSMutableArray array];
    HLSStrip *previousStrip = nil;
    for (HLSStrip *strip in sortedStrips) {
        if (strip.endPosition >= self.positions) {
            HLSLoggerError(@"Strip %@ ends outside range; dropped", strip);
            continue;
        }
        
        if (previousStrip && strip.beginPosition < previousStrip.endPosition) {
            HLSLoggerError(@"Strip %@ overlaps with strip %@; dropped", strip, previousStrip);
            continue;
        }
        [cleanedStrips addObject:strip];
        previousStrip = strip;
    }
    
    [self clear];
    
    self.allStrips = cleanedStrips;
    for (HLSStrip *strip in self.allStrips) {
        HLSStripView *stripView = [self buildStripViewForStrip:strip];
        [stripView setContentFrame:[self frameForStrip:strip]];
        [self addSubview:stripView];
        
        NSValue *stripKey = [NSValue valueWithPointer:strip];
        [self.stripToViewMap setObject:stripView forKey:stripKey];
    }
}

@synthesize stripToViewMap = m_stripToViewMap;

@synthesize positions = m_positions;

- (void)setPositions:(NSUInteger)positions
{
    if (m_positionsUsed) {
        HLSLoggerWarn(@"Number of positions cannot be altered anymore");
        return;
    }
    
    m_positions = positions;
    
    self.defaultLength = m_positions / 10;
}

@synthesize defaultLength = m_defaultLength;

- (void)setDefaultLength:(NSUInteger)defaultLength
{
    if (defaultLength >= self.positions) {
        HLSLoggerWarn(@"Default length exceeds number of positions");
        return;
    }
    
    m_defaultLength = defaultLength;
}

@synthesize enabled = m_enabled;

@synthesize delegate = m_delegate;

#pragma mark Laying out subviews

- (void)layoutSubviews
{
    for (HLSStrip *strip in self.allStrips) {
        HLSStripView *stripView = [self viewForStrip:strip];
        [stripView setContentFrame:[self frameForStrip:strip]];
    }
}

#pragma mark Converting between positions and view coordinates and objects

// Return the x position (in the coordinate system of the container view) corresponding to a given position
- (CGFloat)xPosForPosition:(NSUInteger)position
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return 0.f;
    }    
    
    return ((CGFloat)position / (self.positions - 1.f)) * self.frame.size.width;
}

// Return the position located before xPos (in the coordinate system of the container view)
- (NSUInteger)lowerPositionForXPos:(CGFloat)xPos
{
    return floorf(((self.positions - 1.f) * xPos) / self.frame.size.width);
}

// Return the frame corresponding to a strip (in the coordinate system of the container view)
- (CGRect)frameForStrip:(HLSStrip *)strip
{
    CGFloat beginXPos = [self xPosForPosition:strip.beginPosition];
    CGFloat endXPos = [self xPosForPosition:strip.endPosition];
    return CGRectMake(beginXPos, 
                      0.f, 
                      endXPos - beginXPos,
                      self.frame.size.height);
}

// Create and install the view associated with a strip, and register it into the index
- (HLSStripView *)addViewForStrip:(HLSStrip *)strip
{
    NSValue *stripKey = [NSValue valueWithPointer:strip];
    HLSStripView *stripView = [self.stripToViewMap objectForKey:stripKey];
    if (stripView) {
        HLSLoggerError(@"View already added for strip %@", strip);
        return stripView;
    }
    
    stripView = [self buildStripViewForStrip:strip];    
    [self addSubview:stripView];
    [self.stripToViewMap setObject:stripView forKey:stripKey];
    
    return stripView;
}

// Create the view associated with a strip
- (HLSStripView *)buildStripViewForStrip:(HLSStrip *)strip
{
    UIView *view = nil;
    if ([self.delegate respondsToSelector:@selector(stripContainerViewIsRequestingViewForStrip:)]) {
        view = [self.delegate stripContainerViewIsRequestingViewForStrip:strip];
    }
    
    // If no custom view provied, use default style
    if (! view) {
        view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nut_strip_default_background.png"]] autorelease];
        view.contentStretch = CGRectMake(0.5f, 
                                         0.5f, 
                                         1.f / view.frame.size.width, 
                                         1.f / view.frame.size.height);
    }
    
    HLSStripView *stripView = [[[HLSStripView alloc] initWithStrip:strip view:view] autorelease];
    stripView.delegate = self;
    return stripView;
}

// Remove the view associated with a strip, and unregister it from the index
- (void)removeViewForStrip:(HLSStrip *)strip
{
    HLSStripView *stripView = [self viewForStrip:strip];
    if (stripView) {
        [stripView removeFromSuperview];
    }
    else {
        HLSLoggerError(@"View not added for strip %@", strip);
    }
    
    NSValue *stripKey = [NSValue valueWithPointer:strip];
    [self.stripToViewMap removeObjectForKey:stripKey];
}

// Return the view associated with a strip
- (HLSStripView *)viewForStrip:(HLSStrip *)strip
{
    NSValue *stripKey = [NSValue valueWithPointer:strip];
    HLSStripView *stripView = [self.stripToViewMap objectForKey:stripKey];
    if (! stripView) {
        HLSLoggerError(@"View not found for strip %@", strip);
        return nil;
    }
    return stripView;
}


#pragma mark Strip management

- (BOOL)addStripAtPosition:(NSUInteger)position length:(NSUInteger)length animated:(BOOL)animated
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
        HLSLoggerWarn(@"Length must not exceed number of available positions");
        return NO;
    }
    
    // Find an insertion point
    NSUInteger previousEndPosition = 0;
    NSUInteger nextBeginPosition = self.positions - 1;
    NSUInteger index = 0;
    HLSStrip *newStrip = nil;
    for (HLSStrip *strip in self.allStrips) {
        if (strip.beginPosition <= position && position < strip.endPosition) {
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
    if (index == [self.allStrips count]) {
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
    
    if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldAddStrip:)]) {
        if (! [self.delegate stripContainerView:self shouldAddStrip:newStrip]) {
            HLSLoggerInfo(@"Cancelled creation of strip %@", newStrip);
            return NO;
        }
    }
    
    // Insert the new strip in the correct order so that the array is sorted by beginPosition
    NSMutableArray *strips = [NSMutableArray arrayWithArray:self.allStrips];
    if (index == [self.allStrips count]) {
        [strips addObject:newStrip];
    }
    else {
        [strips insertObject:newStrip atIndex:index];
    }
    self.allStrips = [NSArray arrayWithArray:strips];
    
    [self addViewForStrip:newStrip];
    
    HLSAnimation *animation = [self animationAddingStrip:newStrip];
    [animation playAnimated:animated];
    
    return YES;
}

- (BOOL)addStripAtPosition:(NSUInteger)position animated:(BOOL)animated
{
    return [self addStripAtPosition:position length:self.defaultLength animated:animated];
}

- (BOOL)splitStripAtPosition:(NSUInteger)position animated:(BOOL)animated
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return NO;
    }    
    
    BOOL split = NO;
    NSMutableArray *stripsModified = [NSMutableArray array];
    for (HLSStrip *strip in self.allStrips) {
        if ([strip containsPosition:position] && position != strip.beginPosition && position != strip.endPosition) {
            if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldSplitStrip:)]) {
                if (! [self.delegate stripContainerView:self shouldSplitStrip:strip]) {
                    HLSLoggerInfo(@"Cancelled split of strip %@", strip);
                    return NO;
                }
            }
            
            [self removeViewForStrip:strip];
            
            HLSStrip *subStrip1 = [HLSStrip stripWithBeginPosition:strip.beginPosition endPosition:position];
            [stripsModified addObject:subStrip1];
            [self addViewForStrip:subStrip1];
            
            HLSStrip *subStrip2 = [HLSStrip stripWithBeginPosition:position endPosition:strip.endPosition];
            [stripsModified addObject:subStrip2];
            [self addViewForStrip:subStrip2];
            
            split = YES;
        }
        else {
            [stripsModified addObject:strip];
        }
    }
    self.allStrips = [NSArray arrayWithArray:stripsModified];
    
    return split;
}

- (BOOL)deleteStripsAtPosition:(NSUInteger)position animated:(BOOL)animated
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return NO;
    }
    
    BOOL deleted = NO;
    for (HLSStrip *strip in self.allStrips) {
        if ([strip containsPosition:position]) {
            if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldDeleteStrip:)]) {
                if (! [self.delegate stripContainerView:self shouldDeleteStrip:strip]) {
                    HLSLoggerInfo(@"Cancelled deletion of strip %@", strip);
                    continue;
                }
            }
            
            HLSAnimation *animation = [self animationRemovingStrip:strip];
            [animation playAnimated:animated];
            
            deleted = YES;
        }
    }
    return deleted;
}

- (BOOL)deleteStripWithIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index >= [self.allStrips count]) {
        HLSLoggerWarn(@"Incorrect index");
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldDeleteStrip:)]) {
        HLSStrip *strip = [self.allStrips objectAtIndex:index];
        if (! [self.delegate stripContainerView:self shouldDeleteStrip:strip]) {
            HLSLoggerInfo(@"Cancelled deletion of strip %@", strip);
            return NO;
        }
    }
    
    HLSStrip *strip = [self.allStrips objectAtIndex:index];
    HLSAnimation *animation = [self animationRemovingStrip:strip];
    [animation playAnimated:animated];
    
    return YES;
}

#pragma mark Managing displayed content

- (void)clear
{
    for (HLSStrip *strip in self.allStrips) {
        [self removeViewForStrip:strip];
    }
    self.allStrips = [NSMutableArray array];
    self.stripToViewMap = [NSMutableDictionary dictionary];
}

#pragma mark Animations

- (HLSAnimation *)animationAddingStrip:(HLSStrip *)strip
{
    HLSStripView *stripView = [self viewForStrip:strip];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformMakeScale(1.f/100.f, 1.f/100.f)
                                                                    alphaVariation:0.f];
    animationStep1.duration = 0.;
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformMakeScale(120.f, 110.f)
                                                                    alphaVariation:0.f];
    animationStep2.duration = 0.15;
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformConcat(CGAffineTransformInvert(CGAffineTransformMakeScale(1.f/100.f, 1.f/100.f)), 
                                                                                                           CGAffineTransformInvert(CGAffineTransformMakeScale(120.f, 110.f)))
                                                                    alphaVariation:0.f];
    animationStep3.duration = 0.15;
    HLSAnimation *animation = [HLSAnimation animationWithAnimationSteps:[NSArray arrayWithObjects:animationStep1, animationStep2, animationStep3, nil]];
    animation.delegate = self;
    animation.lockingUI = YES;
    animation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:strip, @"strip", nil];
    animation.tag = kAddStripAnimationTag;
    
    return animation;
}

- (HLSAnimation *)animationRemovingStrip:(HLSStrip *)strip
{
    HLSStripView *stripView = [self viewForStrip:strip];
    
    HLSAnimationStep *animationStep = [HLSAnimationStep animationStepUpdatingView:stripView
                                                               withAlphaVariation:-1.f];
    animationStep.duration = 0.3;
    HLSAnimation *animation = [HLSAnimation animationWithAnimationStep:animationStep];
    animation.delegate = self;
    animation.lockingUI = YES;
    animation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:strip, @"strip", nil];
    animation.tag = kRemoveStripAnimationTag;
    
    return animation;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationDidStop:(HLSAnimation *)animation
{
    if ([animation.tag isEqual:kAddStripAnimationTag]) {
        if ([self.delegate respondsToSelector:@selector(stripContainerView:hasAddedStrip:)]) {
            HLSStrip *newStrip = [animation.userInfo objectForKey:@"strip"];
            [self.delegate stripContainerView:self hasAddedStrip:newStrip];
        }        
    }
    else if ([animation.tag isEqual:kRemoveStripAnimationTag]) {
        HLSStrip *strip = [animation.userInfo objectForKey:@"strip"];
        [self removeViewForStrip:strip];
        
        NSMutableArray *stripsCopy = [NSMutableArray arrayWithArray:self.allStrips];
        [stripsCopy removeObject:strip];
        self.allStrips = [NSArray arrayWithArray:stripsCopy];
    }
}

#pragma mark HLSStripViewDelegate protocol implementation

- (void)stripViewHasBeenClicked:(HLSStripView *)stripView
{
    HLSStrip *strip = stripView.strip;
    
    if (! stripView.edited) {
        if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldEnterEditModeForStrip:)]) {
            if (! [self.delegate stripContainerView:self shouldEnterEditModeForStrip:strip]) {
                HLSLoggerInfo(@"Cancelled entering edit mode for strip %@", strip);
                return;
            }
        }
        
        // Bring the edited strip to the top
        [self bringSubviewToFront:stripView];
        
        [stripView enterEditMode];
        
        if ([self.delegate respondsToSelector:@selector(stripContainerView:didEnterEditModeForStrip:)]) {
            [self.delegate stripContainerView:self didEnterEditModeForStrip:strip];
        }    
    }
    else {
        [stripView exitEditMode];
        
        if ([self.delegate respondsToSelector:@selector(stripContainerView:didExitEditModeForStrip:)]) {
            [self.delegate stripContainerView:self didExitEditModeForStrip:strip];
        }
    }
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    switch ([touch tapCount]) {
        // Double tap to add a strip
        case 2: {
            CGPoint pos = [touch locationInView:self];
            NSUInteger position = [self lowerPositionForXPos:pos.x];
            [self addStripAtPosition:position animated:YES];
            break;
        }
            
        default: {
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)endTouches:(NSSet *)touches animated:(BOOL)animated
{
    
}

#pragma mark Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; positions: %d; strips: %@>", 
            [self class],
            self,
            self.positions,
            self.allStrips];
}

@end
