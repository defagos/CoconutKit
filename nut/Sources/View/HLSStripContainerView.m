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
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSStrip+Friend.h"
#import "HLSStripView.h"

static NSString *kAddStripAnimationTag = @"addStrip";
static NSString *kRemoveStripAnimationTag = @"removeStrip";

// TODO: Set m_positionsUsed to YES somewhere!!!!

@interface HLSStripContainerView () <HLSAnimationDelegate, HLSStripViewDelegate>

- (void)initialize;

@property (nonatomic, retain) NSArray *allStrips;
@property (nonatomic, retain) NSMutableDictionary *stripToViewMap;
@property (nonatomic, retain) HLSStripView *movedStripView;

- (CGRect)activeFrame;

- (CGFloat)xPosForPosition:(NSUInteger)position;
- (NSUInteger)lowerPositionForXPos:(CGFloat)xPos;
- (NSUInteger)upperPositionForXPos:(CGFloat)xPos;
- (NSUInteger)nearestPositionForXPos:(CGFloat)xPos;
- (NSUInteger)nearestInteractiveSnapPositionForXPos:(CGFloat)xPos;
- (CGRect)frameForStrip:(HLSStrip *)strip;
- (CGRect)frameForBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition;
- (CGRect)frameForBeginXPos:(CGFloat)beginXPos endXPos:(CGFloat)endXPos;

- (HLSStripView *)addStripViewForStrip:(HLSStrip *)strip;
- (HLSStripView *)buildStripViewForStrip:(HLSStrip *)strip;
- (void)removeStripViewForStrip:(HLSStrip *)strip;
- (HLSStripView *)stripViewForStrip:(HLSStrip *)strip;
- (HLSStripView *)stripViewAtXPos:(CGFloat)xPos;

- (void)toggleEditModeForStripView:(HLSStripView *)stripView;

- (void)snapStripToNearestPosition;

- (HLSAnimation *)animationAddingStrip:(HLSStrip *)strip;
- (HLSAnimation *)animationRemovingStrip:(HLSStrip *)strip;

- (void)endTouches:(NSSet *)touches;

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
    // TODO: NSUIntegerMax is a bad idea. Should be small enough so that at least one position corresponds to 1 pixel.
    //       1px is not enough, though (cannot be easily clicked), so positions should be even smaller
    self.positions = NSUIntegerMax;
    self.allStrips = [NSMutableArray array];
    self.stripToViewMap = [NSMutableDictionary dictionary];
    self.interactiveSnapFactor = 1;
}

- (void)dealloc
{
    self.allStrips = nil;
    self.stripToViewMap = nil;
    self.movedStripView = nil;
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
        [stripView setContentFrameInParent:[self frameForStrip:strip]];
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
    
    // Reset values depending on the number of positions
    self.defaultLength = m_positions / 10;
    self.interactiveSnapFactor = 1;
}

@synthesize interactiveSnapFactor = m_interactiveSnapFactor;

- (void)setInteractiveSnapFactor:(NSUInteger)interactiveSnapFactor
{
    if (interactiveSnapFactor == 0) {
        HLSLoggerWarn(@"Factor cannot be 0; fixed to 1");
        m_interactiveSnapFactor = 1;
    }
    else if ((self.positions - 1) % interactiveSnapFactor != 0) {
        HLSLoggerWarn(@"Factor %d should divide number of intervals %d exactly; fixed to 1", 
                      interactiveSnapFactor,
                      self.positions - 1);
        m_interactiveSnapFactor = 1;
    }
    else {
        m_interactiveSnapFactor = interactiveSnapFactor;
    }
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

@synthesize movedStripView = m_movedStripView;

@synthesize delegate = m_delegate;

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    [self exitEditModeAnimated:NO];
}

#pragma mark Laying out subviews

- (void)layoutSubviews
{
    for (HLSStrip *strip in self.allStrips) {
        HLSStripView *stripView = [self stripViewForStrip:strip];
        [stripView setContentFrameInParent:[self frameForStrip:strip]];
    }
}

#pragma mark Active frame

// Return the active frame, i.e. the area onto which strips are drawn. This area is smaller than the total available area. The reason
// is that handles used to resize strips are drawn outside the strip view frame. We therefore need a margin on both sides (equal to the
// width of the handles) so that when a strip is completely on the left / on the right, its handles remain in the container view frame.
// If this was not the case, we would not be able to trap touch events as soon a handle is outside the container frame, which would
// prevent the user from grabbing them (making strip resizing impossible!)
- (CGRect)activeFrame
{
    return CGRectMake(kStripViewHandleWidth, 0.f, CGRectGetWidth(self.frame) - 2 * kStripViewHandleWidth, CGRectGetHeight(self.frame));
}

#pragma mark Converting between positions and view coordinates and objects

// Return the x position (in the coordinate system of the container view) corresponding to a given position
- (CGFloat)xPosForPosition:(NSUInteger)position
{
    if (position >= self.positions) {
        HLSLoggerWarn(@"Incorrect position");
        return 0.f;
    }    
    
    CGRect activeFrame = [self activeFrame];
    return kStripViewHandleWidth + ((CGFloat)position / (self.positions - 1)) * CGRectGetWidth(activeFrame);
}

// Return the position located before xPos (in the coordinate system of the container view)
- (NSUInteger)lowerPositionForXPos:(CGFloat)xPos
{
    CGRect activeFrame = [self activeFrame];
    if (floatlt(xPos, CGRectGetMinX(activeFrame)) || floatgt(xPos, CGRectGetMaxX(activeFrame))) {
        HLSLoggerError(@"Position outside range");
        return 0;
    }
    
    return (NSUInteger)floorf(((self.positions - 1) * (xPos - kStripViewHandleWidth)) / CGRectGetWidth(activeFrame));
}

// Return the position located before xPos (in the coordinate system of the container view)
- (NSUInteger)upperPositionForXPos:(CGFloat)xPos
{
    CGRect activeFrame = [self activeFrame];
    if (floatlt(xPos, CGRectGetMinX(activeFrame)) || floatgt(xPos, CGRectGetMaxX(activeFrame))) {
        HLSLoggerError(@"Position outside range");
        return 0;
    }
    
    return (NSUInteger)ceilf(((self.positions - 1) * (xPos - kStripViewHandleWidth)) / CGRectGetWidth(activeFrame));
}

// Return the nearest position for xPos (in the coordinate system of the container view)
- (NSUInteger)nearestPositionForXPos:(CGFloat)xPos
{
    CGRect activeFrame = [self activeFrame];
    if (floatlt(xPos, CGRectGetMinX(activeFrame)) || floatgt(xPos, CGRectGetMaxX(activeFrame))) {
        HLSLoggerError(@"Position outside range");
        return 0;
    }
    
    return (NSUInteger)roundf(((self.positions - 1) * (xPos - kStripViewHandleWidth)) / CGRectGetWidth(activeFrame));
}

// Return the nearest position where we can snap interactively when located in xPos (in the coordinate system of the container view)
- (NSUInteger)nearestInteractiveSnapPositionForXPos:(CGFloat)xPos
{
    NSUInteger position = [self nearestPositionForXPos:xPos];
    return self.interactiveSnapFactor * (NSUInteger)roundf((float)position / self.interactiveSnapFactor);
}

// Return the frame corresponding to a strip (in the coordinate system of the container view)
- (CGRect)frameForStrip:(HLSStrip *)strip
{
    return [self frameForBeginPosition:strip.beginPosition endPosition:strip.endPosition];
}

// Return the frame corresponding to two positions (in the coordinate system of the container view)
- (CGRect)frameForBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition
{
    CGRect activeFrame = [self activeFrame];
    CGFloat beginXPos = [self xPosForPosition:beginPosition];
    CGFloat endXPos = [self xPosForPosition:endPosition];
    return CGRectMake(beginXPos, 
                      0.f, 
                      endXPos - beginXPos,
                      CGRectGetHeight(activeFrame));
}

// Return the frame corresponding to the begin and end x coordinates provided, or CGRectZero if an error occurred. Does
// not snap on positions
- (CGRect)frameForBeginXPos:(CGFloat)beginXPos endXPos:(CGFloat)endXPos
{
    CGRect activeFrame = [self activeFrame];
    if (floatlt(beginXPos, CGRectGetMinX(activeFrame)) || floatgt(beginXPos, CGRectGetMaxX(activeFrame))) {
        HLSLoggerError(@"Begin position outside range");
        return CGRectZero;
    }
    
    if (floatlt(endXPos, CGRectGetMinX(activeFrame)) || floatgt(endXPos, CGRectGetMaxX(activeFrame))) {
        HLSLoggerError(@"End position outside range");
        return CGRectZero;
    }
    
    if (floatge(beginXPos, endXPos)) {
        HLSLoggerError(@"Begin position must be located before end position");
        return CGRectZero;
    }
    
    return CGRectMake(beginXPos,
                      0.f,
                      endXPos - beginXPos,
                      CGRectGetHeight(activeFrame));
}

#pragma mark Strip view management

// Create and install the view associated with a strip, and register it into the index
- (HLSStripView *)addStripViewForStrip:(HLSStrip *)strip
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

// Return the topmost strip view found at the given position, or nil if none. Take into account the full strip view, including the handles
// which are displayed in edit mode
- (HLSStripView *)stripViewAtXPos:(CGFloat)xPos
{
    // Loop through all subviews, from the topmost to the bottommost one
    for (UIView *view in [self.subviews reverseObjectEnumerator]) {
        if ([view isKindOfClass:[HLSStripView class]]) {
            HLSStripView *stripView = (HLSStripView *)view;
            // Point in the middle along the y-axis (we are only interested about the x-axis anyway)
            if (CGRectContainsPoint(stripView.frame, CGPointMake(xPos, CGRectGetMidY(stripView.frame)))) {
                return stripView;
            }
        }
    }
    return nil;
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
                                         1.f / CGRectGetWidth(view.frame), 
                                         1.f / CGRectGetHeight(view.frame));
    }
    
    HLSStripView *stripView = [[[HLSStripView alloc] initWithStrip:strip contentView:view] autorelease];
    stripView.delegate = self;
    stripView.exclusiveTouch = YES;
    return stripView;
}

// Remove the view associated with a strip, and unregister it from the index
- (void)removeStripViewForStrip:(HLSStrip *)strip
{
    HLSStripView *stripView = [self stripViewForStrip:strip];
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
- (HLSStripView *)stripViewForStrip:(HLSStrip *)strip
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
    
    [self addStripViewForStrip:newStrip];
    
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
            
            [self removeStripViewForStrip:strip];
            
            HLSStrip *subStrip1 = [HLSStrip stripWithBeginPosition:strip.beginPosition endPosition:position];
            [stripsModified addObject:subStrip1];
            [self addStripViewForStrip:subStrip1];
            
            HLSStrip *subStrip2 = [HLSStrip stripWithBeginPosition:position endPosition:strip.endPosition];
            [stripsModified addObject:subStrip2];
            [self addStripViewForStrip:subStrip2];
            
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
    
    HLSStrip *strip = [self.allStrips objectAtIndex:index];
    return [self deleteStrip:strip animated:animated];
}

- (BOOL)deleteStrip:(HLSStrip *)strip animated:(BOOL)animated
{
    if ([self.allStrips indexOfObject:strip] == NSNotFound) {
        HLSLoggerWarn(@"This strip is not loaded into this container");
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldDeleteStrip:)]) {
        if (! [self.delegate stripContainerView:self shouldDeleteStrip:strip]) {
            HLSLoggerInfo(@"Cancelled deletion of strip %@", strip);
            return NO;
        }
    }
    
    HLSAnimation *animation = [self animationRemovingStrip:strip];
    [animation playAnimated:animated];
    
    return YES;    
}

- (BOOL)moveStripWithIndex:(NSUInteger)index newPosition:(NSUInteger)newPosition newLength:(NSUInteger)newLength animated:(BOOL)animated
{
    // TODO:
    return NO;
}

- (BOOL)moveStrip:(HLSStrip *)strip newPosition:(NSUInteger)newPosition newLength:(NSUInteger)newLength animated:(BOOL)animated
{
    // TODO:
    return NO;
}

#pragma mark Edit mode

- (void)toggleEditModeForStripView:(HLSStripView *)stripView
{
    HLSStrip *strip = stripView.strip;
    
    if (! stripView.edited) {
        if ([self.delegate respondsToSelector:@selector(stripContainerView:shouldEnterEditModeForStrip:)]) {
            if (! [self.delegate stripContainerView:self shouldEnterEditModeForStrip:strip]) {
                HLSLoggerInfo(@"Cancelled entering edit mode for strip %@", strip);
                return;
            }
        }
        
        // If any other strip was in edit mode, exit
        [self exitEditModeAnimated:YES];
        
        // Bring the edited strip to the top
        [self bringSubviewToFront:stripView];
        
        [stripView enterEditModeAnimated:YES];        
    }
    else {
        [stripView exitEditModeAnimated:YES];
    }
}

#pragma mark Moving strips

- (void)snapStripToNearestPosition
{
    // Dragging: Snap to nearest position
    if (self.movedStripView) {
        // Calculate positions nearest snap positions. Must avoid zero-length strips, therefore the additional MIN / MAX
        NSUInteger beginPosition = 0;
        NSUInteger endPosition = 0;
        if (m_draggingLeftHandle) {
            endPosition = [self nearestPositionForXPos:CGRectGetMaxX(self.movedStripView.contentFrameInParent)];
            beginPosition = MIN([self nearestInteractiveSnapPositionForXPos:CGRectGetMinX(self.movedStripView.contentFrameInParent)], endPosition - 1);
        }
        else {
            beginPosition = [self nearestPositionForXPos:CGRectGetMinX(self.movedStripView.contentFrameInParent)];
            endPosition = MAX([self nearestInteractiveSnapPositionForXPos:CGRectGetMaxX(self.movedStripView.contentFrameInParent)], beginPosition + 1);
        }
        
        // Adjust the strip view accordingly
        self.movedStripView.contentFrameInParent = [self frameForBeginPosition:beginPosition endPosition:endPosition];
        
        // Adjust the strip object accordingly
        self.movedStripView.strip.beginPosition = beginPosition;
        self.movedStripView.strip.endPosition = endPosition;
        
        if ([self.delegate respondsToSelector:@selector(stripContainerView:didMoveStrip:animated:)]) {
            [self.delegate stripContainerView:self didMoveStrip:self.movedStripView.strip animated:YES];
        }
    }
}

#pragma mark Managing displayed content

- (void)clear
{
    for (HLSStrip *strip in self.allStrips) {
        [self removeStripViewForStrip:strip];
    }
    self.allStrips = [NSMutableArray array];
    self.stripToViewMap = [NSMutableDictionary dictionary];
}

#pragma mark Edit mode

- (void)exitEditModeAnimated:(BOOL)animated
{
    for (HLSStripView *stripView in [self.stripToViewMap allValues]) {
        if (stripView.edited) {
            [stripView exitEditModeAnimated:animated];
        }
    }
}

#pragma mark Animations

- (HLSAnimation *)animationAddingStrip:(HLSStrip *)strip
{
    HLSStripView *stripView = [self stripViewForStrip:strip];
    
    HLSAnimationStep *animationStep1 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformMakeScale(1.f / 100.f, 1.f / 100.f)
                                                                    alphaVariation:0.f];
    animationStep1.duration = 0.;
    HLSAnimationStep *animationStep2 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformMakeScale(120.f, 110.f)
                                                                    alphaVariation:0.f];
    animationStep2.duration = 0.15;
    HLSAnimationStep *animationStep3 = [HLSAnimationStep animationStepUpdatingView:stripView
                                                                     withTransform:CGAffineTransformConcat(CGAffineTransformInvert(CGAffineTransformMakeScale(1.f / 100.f, 1.f / 100.f)), 
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
    HLSStripView *stripView = [self stripViewForStrip:strip];
    
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

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqual:kAddStripAnimationTag]) {
        if ([self.delegate respondsToSelector:@selector(stripContainerView:didAddStrip:animated:)]) {
            HLSStrip *newStrip = [animation.userInfo objectForKey:@"strip"];
            [self.delegate stripContainerView:self didAddStrip:newStrip animated:animated];
        }
    }
    else if ([animation.tag isEqual:kRemoveStripAnimationTag]) {
        HLSStrip *strip = [animation.userInfo objectForKey:@"strip"];
        [self removeStripViewForStrip:strip];
        
        NSMutableArray *stripsCopy = [NSMutableArray arrayWithArray:self.allStrips];
        [stripsCopy removeObject:strip];
        self.allStrips = [NSArray arrayWithArray:stripsCopy];
    }
}

#pragma mark HLSStripViewDelegate protocol implementation

- (void)stripView:(HLSStripView *)stripView didEnterEditModeAnimated:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(stripContainerView:didEnterEditModeForStrip:)]) {
        [self.delegate stripContainerView:self didEnterEditModeForStrip:stripView.strip];
    }
}

- (void)stripView:(HLSStripView *)stripView didExitEditModeAnimated:(BOOL)animated
{    
    if ([self.delegate respondsToSelector:@selector(stripContainerView:didExitEditModeForStrip:)]) {
        [self.delegate stripContainerView:self didExitEditModeForStrip:stripView.strip];
    }
}

#pragma mark Touch events

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    HLSStripView *stripView = [self stripViewAtXPos:pos.x];
    // Strip view found; the two tests at the end are not only less costly than CGRectContainsPoint, but also
    // guarantee that we cannot grab a handle while another one is already grabbed (otherwise, when shrinking
    // a strip, we could "transfer" the grab from one handle to the other one, which works but is not user-friendly)
    if (stripView && ! m_draggingLeftHandle && ! m_draggingRightHandle) {
        if (CGRectContainsPoint([stripView leftHandleFrameInParent], pos)) {
            if (! m_draggingLeftHandle) {
                m_draggingLeftHandle = YES;
                
                m_handlePreviousXPos = pos.x;
                self.movedStripView = stripView;
                
                if ([self.delegate respondsToSelector:@selector(stripContainerView:willMoveStrip:animated:)]) {
                    [self.delegate stripContainerView:self willMoveStrip:self.movedStripView.strip animated:YES];
                }
            }            
        }
        else if (CGRectContainsPoint([stripView rightHandleFrameInParent], pos)) {
            if (! m_draggingRightHandle) {
                m_draggingRightHandle = YES;
                
                m_handlePreviousXPos = pos.x;
                self.movedStripView = stripView;
                
                if ([self.delegate respondsToSelector:@selector(stripContainerView:willMoveStrip:animated:)]) {
                    [self.delegate stripContainerView:self willMoveStrip:self.movedStripView.strip animated:YES];
                }
            }    
        }
    }
    
    // Not snapping strip views when dragging. Snapping would be weird since the handles would not follow the finger
    // (and this would rise technical issues due to the fact that handles do not move between snapping positions). Our
    // best bet is therefore to stretch the strip rectangle when resizing and to snap it when done
    if (m_draggingLeftHandle || m_draggingRightHandle) {
        CGFloat beginXPos = 0.f;
        CGFloat endXPos = 0.f;
        if (m_draggingLeftHandle) {
            CGFloat leftSizeIncrement = m_handlePreviousXPos - pos.x;
            CGRect activeFrame = [self activeFrame];
            beginXPos = floatmax(CGRectGetMinX(self.movedStripView.contentFrameInParent) - leftSizeIncrement,
                                 CGRectGetMinX(activeFrame)  /* avoid getting out to the left */);
            endXPos = CGRectGetMaxX(self.movedStripView.contentFrameInParent);
            m_stripJustMadeLarger = floatge(leftSizeIncrement, 0.f);
            
            // Guarantee minimal strip size: the interval between two positions
            if (floatle(endXPos - beginXPos, CGRectGetWidth(activeFrame) / (self.positions - 1))) {
                beginXPos = endXPos - CGRectGetWidth(activeFrame) / (self.positions - 1);
                self.movedStripView.contentFrameInParent = [self frameForBeginXPos:beginXPos
                                                                           endXPos:endXPos];
                return;
            }
        }
        else {
            CGFloat rightSizeIncrement = pos.x - m_handlePreviousXPos;
            CGRect activeFrame = [self activeFrame];
            beginXPos = CGRectGetMinX(self.movedStripView.contentFrameInParent);
            endXPos = floatmin(CGRectGetMaxX(self.movedStripView.contentFrameInParent) + rightSizeIncrement,
                               CGRectGetMaxX(activeFrame)  /* avoid getting out to the right */);
            m_stripJustMadeLarger = floatge(rightSizeIncrement, 0.f);
            
            // Guarantee minimal strip size: the interval between two positions
            if (floatle(endXPos - beginXPos, CGRectGetWidth(activeFrame) / (self.positions - 1))) {
                endXPos = beginXPos + CGRectGetWidth(activeFrame) / (self.positions - 1);
                self.movedStripView.contentFrameInParent = [self frameForBeginXPos:beginXPos
                                                                           endXPos:endXPos];
                return;
            }
        }
        
        // Calculate the new strip content frame corresponding to the new finger position
        CGRect contentFrame = [self frameForBeginXPos:beginXPos
                                              endXPos:endXPos];
        
        // If dragging a handle to the left, we must stop if we encounter another strip
        NSUInteger movedStripIndex = [self.allStrips indexOfObject:self.movedStripView.strip];
        NSAssert(movedStripIndex != NSNotFound, @"Strip not found");
        if (m_draggingLeftHandle && movedStripIndex > 0) {
            HLSStrip *leftStrip = [self.allStrips objectAtIndex:movedStripIndex - 1];
            HLSStripView *leftNeighbouringStripView = [self stripViewForStrip:leftStrip];
            if (CGRectIntersectsRect(contentFrame, leftNeighbouringStripView.frame)) {
                self.movedStripView.contentFrameInParent = [self frameForBeginXPos:CGRectGetMaxX(leftNeighbouringStripView.frame)
                                                                           endXPos:endXPos];
                return;
            }
        }
        // Similar when dragging a handle to the right
        if (m_draggingRightHandle && movedStripIndex < [self.allStrips count] - 1) {
            HLSStrip *rightStrip = [self.allStrips objectAtIndex:movedStripIndex + 1];
            HLSStripView *rightNeighbouringStripView = [self stripViewForStrip:rightStrip];
            if (CGRectIntersectsRect(contentFrame, rightNeighbouringStripView.frame)) {
                self.movedStripView.contentFrameInParent = [self frameForBeginXPos:beginXPos 
                                                                           endXPos:CGRectGetMinX(rightNeighbouringStripView.frame)];
                return;
            }
        }
        
        // No obstacle on the left or right. Can set the content frame and save the new handle position
        self.movedStripView.contentFrameInParent = contentFrame;
        m_handlePreviousXPos = pos.x;
    }    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint pos = [touch locationInView:self];
    HLSStripView *stripView = [self stripViewAtXPos:pos.x];
    // Strip view found at the finger location. This must not be the result of the finger reaching another strip
    // while dragging a handle, otherwise we would switch from dragging to edit mode on another strip, which is ugly
    if (stripView && ! self.movedStripView) {
        // Content view part of a strip view touched. Toggle edit mode on or off
        if (CGRectContainsPoint(stripView.contentFrameInParent, pos)) {
            [self toggleEditModeForStripView:stripView];
        }
    }
    // No strip view found at the finger location
    else {
        switch ([touch tapCount]) {
            // Single tap exits edit mode if not dragging
            case 1: {
                if (! self.movedStripView) {
                    [self exitEditModeAnimated:YES];
                }
                break;
            }
                
            // Double tap to add a strip
            case 2: {
                // Exit edit mode if a strip was being edited
                [self exitEditModeAnimated:YES];
                
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
    
    [self endTouches:touches];    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If was dragging: Snap to nearest position
    if (self.movedStripView) {
        [self snapStripToNearestPosition];
    }
    
    [self endTouches:touches];
}

- (void)endTouches:(NSSet *)touches
{    
    // Dragging: Snap to nearest position
    if (self.movedStripView) {
        [self snapStripToNearestPosition];
    }
    
    self.movedStripView = nil;
    
    m_draggingLeftHandle = NO;
    m_draggingRightHandle = NO;
    m_stripJustMadeLarger = NO;
    
    m_handlePreviousXPos = 0.f;
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
