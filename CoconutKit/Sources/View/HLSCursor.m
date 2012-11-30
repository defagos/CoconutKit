//
//  HLSCursor.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSCursor.h"

#import "HLSAnimation.h"
#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSViewAnimationStep.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

@interface HLSCursor ()

- (void)hlsCursorInit;

@property (nonatomic, retain) NSArray *elementWrapperViews;
@property (nonatomic, retain) NSArray *elementWrapperViewSizeValues;

@property (nonatomic, retain) UIView *pointerContainerView;

- (UIView *)elementViewForIndex:(NSUInteger)index selected:(BOOL)selected;
- (UIView *)elementWrapperViewForIndex:(NSUInteger)index;

- (CGFloat)xPosForIndex:(NSUInteger)index;
- (NSUInteger)indexForXPos:(CGFloat)xPos;

- (void)showElementViewAtIndex:(NSUInteger)index selected:(BOOL)selected;

- (CGRect)pointerFrameForIndex:(NSUInteger)index;
- (CGRect)pointerFrameForXPos:(CGFloat)xPos;

- (void)clear;

@end

@implementation HLSCursor

#pragma mark Object creation and destruction

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self hlsCursorInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self hlsCursorInit];
    }
    return self;
}

- (void)dealloc
{
    self.elementWrapperViews = nil;
    self.elementWrapperViewSizeValues = nil;
    
    // Very special case here. Cannot use the property since it cannot change the pointer view once set!
    [m_pointerView release];
    
    self.pointerContainerView = nil;
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)hlsCursorInit
{
    self.pointerViewTopLeftOffset = CGSizeMake(-10.f, -10.f);
    self.pointerViewBottomRightOffset = CGSizeMake(10.f, 10.f);
    self.animationDuration = 0.2;
}

#pragma mark Accessors and mutators

@synthesize elementWrapperViews = m_elementWrapperViews;

@synthesize elementWrapperViewSizeValues = m_elementWrapperViewSizeValues;

@synthesize pointerContainerView = m_pointerContainerView;

@synthesize pointerView = m_pointerView;

- (void)setPointerView:(UIView *)pointerView
{
    if (m_pointerView) {
        HLSLoggerError(@"Cannot change the pointer view once it has been set");
        return;
    }
    
    m_pointerView = [pointerView retain];
}

@synthesize animationDuration = m_animationDuration;

@synthesize pointerViewTopLeftOffset = m_pointerViewTopLeftOffset;

@synthesize pointerViewBottomRightOffset = m_pointerViewBottomRightOffset;

@synthesize dataSource = m_dataSource;

@synthesize delegate = m_delegate;

#pragma mark Layout

- (void)layoutSubviews
{
    // Create subviews views lazily the first time they are needed; not doing this in init allows clients to customize
    // the views before they are displayed
    if (! m_viewsCreated) {
        // Create the subview set
        self.elementWrapperViews = [NSArray array];
        self.elementWrapperViewSizeValues = [NSArray array];
        
        // Check the data source
        NSUInteger nbrElements = [self.dataSource numberOfElementsForCursor:self];
        if (nbrElements == 0) {
            HLSLoggerError(@"Cursor data source is empty");
            return;
        }
        
        // Fill with views generated from the data source
        for (NSInteger index = 0; index < nbrElements; ++index) {
            UIView *elementWrapperView = [self elementWrapperViewForIndex:index];
            [self addSubview:elementWrapperView];
            self.elementWrapperViews = [self.elementWrapperViews arrayByAddingObject:elementWrapperView];
            
            // The original size needs to be saved separately (since views are not created again)
            self.elementWrapperViewSizeValues = [self.elementWrapperViewSizeValues arrayByAddingObject:[NSValue valueWithCGSize:elementWrapperView.frame.size]];
        }
    }
    
    // Calculate the needed total size to display all elements
    CGFloat requiredWidth = floatmax(-self.pointerViewTopLeftOffset.width, 0.f) + floatmax(self.pointerViewBottomRightOffset.width, 0.f);
    CGFloat requiredHeight = 0.f;
    for (NSValue *elementWrapperViewSizeValue in self.elementWrapperViewSizeValues) {
        CGSize elementWrapperViewSize = [elementWrapperViewSizeValue CGSizeValue];
        requiredWidth += elementWrapperViewSize.width;
        
        if (floatgt(elementWrapperViewSize.height, requiredHeight)) {
            requiredHeight = elementWrapperViewSize.height;
        }
    }
    requiredHeight += floatmax(-self.pointerViewTopLeftOffset.height, 0.f) + floatmax(self.pointerViewBottomRightOffset.height, 0.f);
    
    // Cursor large enough so that everything fits in: Add space between elements
    CGFloat widthScaleFactor = 1.f;
    if (floatle(requiredWidth, CGRectGetWidth(self.frame))) {
        m_spacing = (CGRectGetWidth(self.frame) - requiredWidth) / ([self.elementWrapperViews count] - 1);
    }
    // Not large enough: Scale all views so that they can fit with no space in between
    else {
        widthScaleFactor = CGRectGetWidth(self.frame) / requiredWidth;
        m_spacing = 0.f;
    }
    
    // Cursor not tall enough: Scale all views so that they can fit vertically
    CGFloat heightScaleFactor = 1.f;
    if (floatgt(requiredHeight, CGRectGetHeight(self.frame))) {
        heightScaleFactor = CGRectGetHeight(self.frame) / requiredHeight;
    }
    
    // Adjust individual frames so that the element views are centered within the available frame
    CGFloat xPos = floatmax(-self.pointerViewTopLeftOffset.width, 0.f);
    NSUInteger i = 0;
    for (UIView *elementWrapperView in self.elementWrapperViews) {
        CGSize elementWrapperViewSize = [[self.elementWrapperViewSizeValues objectAtIndex:i] CGSizeValue];
        
        // Centered in main frame
        elementWrapperView.frame = CGRectMake(floorf(xPos),
                                              floorf((CGRectGetHeight(self.frame) - heightScaleFactor * elementWrapperViewSize.height) / 2.f),
                                              widthScaleFactor * elementWrapperViewSize.width,
                                              heightScaleFactor * elementWrapperViewSize.height);
        xPos += CGRectGetWidth(elementWrapperView.frame) + m_spacing;
        
        ++i;
    }
    
    if (! m_viewsCreated) {
        // If no custom pointer view specified, create a default one
        if (! self.pointerView) {
            UIImage *pointerImage = [UIImage imageNamed:@"CoconutKit-resources.bundle/CursorDefaultPointer.png"];
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:pointerImage] autorelease];
            imageView.contentStretch = CGRectMake(0.5f,
                                                  0.5f,
                                                  1.f / CGRectGetWidth(imageView.frame),
                                                  1.f / CGRectGetHeight(imageView.frame));
            self.pointerView = imageView;
        }
        
        if (m_initialIndex >= [self.elementWrapperViews count]) {
            m_initialIndex = 0;
            HLSLoggerWarn(@"Initial index too large; fixed");
        }
        
        // Create a view to container the pointer view. This avoid issues with transparent pointer views
        self.pointerContainerView = [[[UIView alloc] initWithFrame:self.pointerView.bounds] autorelease];
        self.pointerView.frame = self.pointerContainerView.bounds;
        self.pointerContainerView.backgroundColor = [UIColor clearColor];
        self.pointerContainerView.autoresizesSubviews = YES;
        self.pointerContainerView.exclusiveTouch = YES;
        
        self.pointerView.autoresizingMask = HLSViewAutoresizingAll;
        [self.pointerContainerView addSubview:self.pointerView];
        [self addSubview:self.pointerContainerView];
        
        m_creatingViews = YES;
        
        [self setSelectedIndex:m_initialIndex animated:NO];
        
        m_viewsCreated = YES;
    }
    else if (! m_dragging && ! m_moving) {
        self.pointerContainerView.frame = [self pointerFrameForIndex:m_selectedIndex];
    }
}

- (UIView *)elementViewForIndex:(NSUInteger)index selected:(BOOL)selected
{
    // First check if a custom view is used
    if ([self.dataSource respondsToSelector:@selector(cursor:viewAtIndex:selected:)]) {
        // The size must accomodate both the selected and non-selected versions of an element view (i.e. be the largest).
        // To avoid changing the frame of the views we receive, we simply find the rectangle in which both versions fit,
        // then we create a view with this size and we put the view we receive at its center.
        UIView *elementView = [self.dataSource cursor:self viewAtIndex:index selected:selected];
        if (elementView) {
            return elementView;
        }
    }
    
    // Check if a bare label is used
    if ([self.dataSource respondsToSelector:@selector(cursor:titleAtIndex:)]) {
        // Title
        NSString *title = [self.dataSource cursor:self titleAtIndex:index];
        if ([title length] == 0) {
            HLSLoggerWarn(@"Empty title string at index %d", index);
        }
        
        // Font. If not defined by the data source, use standard font
        UIFont *font = nil;
        UIFont *otherFont = nil;
        if ([self.dataSource respondsToSelector:@selector(cursor:fontAtIndex:selected:)]) {
            font = [self.dataSource cursor:self fontAtIndex:index selected:selected];
            otherFont = [self.dataSource cursor:self fontAtIndex:index selected:! selected];
        }
        if (! font) {
            font = [UIFont systemFontOfSize:17.f];
        }
        
        // Text color. If not defined by the data source, use standard colors
        UIColor *textColor = nil;
        if ([self.dataSource respondsToSelector:@selector(cursor:textColorAtIndex:selected:)]) {
            textColor = [self.dataSource cursor:self textColorAtIndex:index selected:selected];
        }
        if (! textColor) {
            textColor = selected ? [UIColor blackColor] : [UIColor grayColor];
        }
        
        // Shadow color. If not defined by the data source, none
        UIColor *shadowColor = nil;
        if ([self.dataSource respondsToSelector:@selector(cursor:shadowColorAtIndex:selected:)]) {
            shadowColor = [self.dataSource cursor:self shadowColorAtIndex:index selected:selected];
        }
        
        // Shadow offset. If not defined, default value (CGSizeMake(0, -1), see UILabel documentation)
        CGSize shadowOffset = kCursorShadowOffsetDefault;
        if ([self.dataSource respondsToSelector:@selector(cursor:shadowOffsetAtIndex:selected:)]) {
            shadowOffset = [self.dataSource cursor:self shadowOffsetAtIndex:index selected:selected];
        }
        
        // Create a label with appropriate size. The size must accomodate both the font sizes for selected and non-selected
        // states
        CGSize titleSize = [title sizeWithFont:font];
        CGSize otherTitleSize = [title sizeWithFont:otherFont];
        UILabel *elementLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                                           0.f,
                                                                           floatmax(titleSize.width, otherTitleSize.width),
                                                                           floatmax(titleSize.height, otherTitleSize.height))]
                                 autorelease];
        elementLabel.text = title;
        elementLabel.backgroundColor = [UIColor clearColor];
        elementLabel.font = font;
        elementLabel.textColor = textColor;
        elementLabel.shadowColor = shadowColor;
        elementLabel.shadowOffset = shadowOffset;
        elementLabel.textAlignment = UITextAlignmentCenter;
        elementLabel.autoresizingMask = HLSViewAutoresizingAll;
        
        return elementLabel;
    }
    
    // Incorrect data source implementation
    HLSLoggerError(@"Cursor data source must either implement cursor:viewAtIndex: or cursor:titleAtIndex:");
    return nil;
}

- (UIView *)elementWrapperViewForIndex:(NSUInteger)index
{
    UIView *elementView = [self elementViewForIndex:index selected:NO];
    UIView *selectedElementView = [self elementViewForIndex:index selected:YES];
    
    if (! elementView || ! selectedElementView) {
        // Incorrect data source implementation
        HLSLoggerError(@"Cursor data source must either implement cursor:viewAtIndex: or cursor:titleAtIndex:");
        return nil;
    }
    
    UIView *wrapperView = [[[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                    0.f,
                                                                    floatmax(CGRectGetWidth(elementView.frame), CGRectGetWidth(selectedElementView.frame)),
                                                                    floatmax(CGRectGetHeight(elementView.frame), CGRectGetHeight(selectedElementView.frame)))] autorelease];
    wrapperView.backgroundColor = [UIColor clearColor];
    
    [wrapperView addSubview:elementView];
    elementView.center = wrapperView.center;
    
    [wrapperView addSubview:selectedElementView];
    selectedElementView.center = wrapperView.center;
    selectedElementView.hidden = YES;
    
    return wrapperView;
}

#pragma mark Pointer management

- (NSUInteger)selectedIndex
{
    return m_selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (m_creatingViews) {
        if ([self.elementWrapperViews count] > 0 && selectedIndex >= [self.elementWrapperViews count]) {
            HLSLoggerWarn(@"Index outside range. Set to last index");
            selectedIndex = [self.elementWrapperViews count] - 1;
        }
        
        HLSViewAnimation *moveViewAnimation11 = [HLSViewAnimation animation];
        [moveViewAnimation11 transformFromRect:self.pointerContainerView.frame
                                        toRect:[self pointerFrameForIndex:selectedIndex]];
        HLSViewAnimationStep *moveAnimationStep1 = [HLSViewAnimationStep animationStep];
        moveAnimationStep1.duration = self.animationDuration;
        [moveAnimationStep1 addViewAnimation:moveViewAnimation11 forView:self.pointerContainerView];
        
        HLSAnimation *moveAnimation = [HLSAnimation animationWithAnimationStep:moveAnimationStep1];
        moveAnimation.tag = @"move";
        moveAnimation.lockingUI = YES;
        moveAnimation.delegate = self;
        moveAnimation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:selectedIndex],
                                  @"targetIndex", nil];
        [moveAnimation playAnimated:animated];
    }
    else {
        // Will only be used if setSelectedIndex has been called before the views are actually created; not
        // wrapped in an "if (! m_viewsCreated) {...}" test, though. This way, when the cursor is reloaded,
        // the most recently set value is used as initial index
        m_initialIndex = selectedIndex;
    }
}

- (void)showElementViewAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if (index >= [self.elementWrapperViews count]) {
        return;
    }
    
    UIView *elementWrapperView = [self.elementWrapperViews objectAtIndex:index];
    
    UIView *elementView = [elementWrapperView.subviews objectAtIndex:0];
    elementView.hidden = selected;
    
    UIView *selectedElementView = [elementWrapperView.subviews objectAtIndex:1];
    selectedElementView.hidden = ! selected;
}

- (CGFloat)xPosForIndex:(NSUInteger)index
{
    if ([self.elementWrapperViews count] == 0) {
        return 0.f;
    }
    
    if (index >= [self.elementWrapperViews count]) {
        HLSLoggerError(@"Invalid index");
        return 0.f;
    }
    
    UIView *elementWrapperView = [self.elementWrapperViews objectAtIndex:index];
    return elementWrapperView.center.x;
}

- (NSUInteger)indexForXPos:(CGFloat)xPos
{
    NSUInteger index = 0;
    for (UIView *elementWrapperView in self.elementWrapperViews) {
        if (floatge(xPos, CGRectGetMinX(elementWrapperView.frame) - m_spacing / 2.f)
            && floatle(xPos, CGRectGetMinX(elementWrapperView.frame) + CGRectGetWidth(elementWrapperView.frame) + m_spacing / 2.f)) {
            return index;
        }
        ++index;
    }
    
    // No match found; return leftmost or rightmost element view
    UIView *firstElementWrapperView = [self.elementWrapperViews firstObject_hls];
    if (floatlt(xPos, CGRectGetMinX(firstElementWrapperView.frame) - m_spacing / 2.f)) {
        return 0;
    }
    else {
        return [self.elementWrapperViews count] - 1;
    }
}

- (CGRect)pointerFrameForIndex:(NSUInteger)index
{
    CGFloat xPos = [self xPosForIndex:index];
    return [self pointerFrameForXPos:xPos];
}

// xPos is here where the pointer is located, i.e. the center of the pointer rectangle
- (CGRect)pointerFrameForXPos:(CGFloat)xPos
{
    // Find the index of the element view whose x center coordinate is the first >= xPos along the x axis
    NSUInteger index = 0;
    for (UIView *elementWrapperView in self.elementWrapperViews) {
        if (floatle(xPos, elementWrapperView.center.x)) {
            break;
        }
        ++index;
    }
    
    // Too far on the left; cursor around the first view
    CGRect pointerRect;
    if (index == 0) {
        UIView *firstElementWrapperView = [self.elementWrapperViews firstObject_hls];
        pointerRect = firstElementWrapperView.frame;
    }
    // Too far on the right; cursor around the last view
    else if (index == [self.elementWrapperViews count]) {
        UIView *lastElementWrapperView = [self.elementWrapperViews lastObject];
        pointerRect = lastElementWrapperView.frame;
    }
    // Cursor in between views with indices index-1 and index. Interpolate
    else {
        UIView *previousElementWrapperView = [self.elementWrapperViews objectAtIndex:index - 1];
        UIView *nextElementWrapperView = [self.elementWrapperViews objectAtIndex:index];
        
        // Linear interpolation
        CGFloat width = ((xPos - nextElementWrapperView.center.x) * CGRectGetWidth(previousElementWrapperView.frame)
                         + (previousElementWrapperView.center.x - xPos) * CGRectGetWidth(nextElementWrapperView.frame)) / (previousElementWrapperView.center.x - nextElementWrapperView.center.x);
        CGFloat height = ((xPos - nextElementWrapperView.center.x) * CGRectGetHeight(previousElementWrapperView.frame)
                          + (previousElementWrapperView.center.x - xPos) * CGRectGetHeight(nextElementWrapperView.frame)) / (previousElementWrapperView.center.x - nextElementWrapperView.center.x);
        
        pointerRect = CGRectMake(xPos - width / 2.f,
                                 (CGRectGetHeight(self.frame) - height) / 2.f,
                                 width,
                                 height);
    }
    
    // Adjust the rect according to the offsets to be applied
    pointerRect = CGRectMake(floorf(CGRectGetMinX(pointerRect) + self.pointerViewTopLeftOffset.width),
                             floorf(CGRectGetMinY(pointerRect) + self.pointerViewTopLeftOffset.height),
                             floorf(CGRectGetWidth(pointerRect) - self.pointerViewTopLeftOffset.width + self.pointerViewBottomRightOffset.width),
                             floorf(CGRectGetHeight(pointerRect) - self.pointerViewTopLeftOffset.height + self.pointerViewBottomRightOffset.height));
    
    return pointerRect;
}

#pragma mark Managing contents

- (void)reloadData
{
    [self clear];
    [self setNeedsLayout];
}

- (void)clear
{
    // Clear all views
    for (UIView *view in self.elementWrapperViews) {
        [view removeFromSuperview];
    }
    self.elementWrapperViews = nil;
    self.elementWrapperViewSizeValues = nil;
    
    [self.pointerContainerView removeFromSuperview];
    self.pointerContainerView = nil;
    
    m_selectedIndex = 0;
    m_viewsCreated = NO;
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_holding = YES;
    
    CGPoint point = [[touches anyObject] locationInView:self];
    NSUInteger index = [self indexForXPos:point.x];
    
    if ([self.delegate respondsToSelector:@selector(cursor:didTouchDownNearIndex:)]) {
        [self.delegate cursor:self didTouchDownNearIndex:index];
    }
    
    if (index != m_selectedIndex) {
        [self setSelectedIndex:index animated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    // Start dragging
    if (! m_dragging) {
        // Check that we are actually grabbing the pointer view
        if (CGRectContainsPoint(self.pointerContainerView.frame, point)) {
            m_dragging = YES;
            
            // Offset between the point where the finger touches the screen when dragging begins and initial center
            // of the view which will be moved. This makes it possible to compensate this initial offset so that
            // the view frame does not "jump" at the finger location (so that the finger is then at the view center) once
            // the first finger motion is detected. Instead, the frame will nicely follow the finger, even if it was not
            // initially touched at its center
            m_initialDraggingXOffset = point.x - self.pointerContainerView.center.x;
            
            [self showElementViewAtIndex:m_selectedIndex selected:NO];
            
            if (! m_moved) {
                if ([self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
                    [self.delegate cursor:self didMoveFromIndex:m_selectedIndex];
                }                
            }
            
            if ([self.delegate respondsToSelector:@selector(cursorDidStartDragging:nearIndex:)]) {
                [self.delegate cursorDidStartDragging:self nearIndex:m_selectedIndex];
            }
        }
    }
    // Dragging
    else {
        CGFloat xPos = point.x - m_initialDraggingXOffset;
        self.pointerContainerView.frame = [self pointerFrameForXPos:xPos];
        
        if ([self.delegate respondsToSelector:@selector(cursor:didDragNearIndex:)]) {
            [self.delegate cursor:self didDragNearIndex:[self indexForXPos:xPos]];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    NSUInteger index = [self indexForXPos:point.x];
    
    if (m_dragging) {
        if ([self.delegate respondsToSelector:@selector(cursorDidStopDragging:nearIndex:)]) {
            [self.delegate cursorDidStopDragging:self nearIndex:index];
        }
        
        HLSViewAnimation *snapViewAnimation11 = [HLSViewAnimation animation];
        [snapViewAnimation11 transformFromRect:self.pointerContainerView.frame toRect:[self pointerFrameForIndex:index]];
        HLSViewAnimationStep *snapAnimationStep1 = [HLSViewAnimationStep animationStep];
        snapAnimationStep1.duration = self.animationDuration;
        [snapAnimationStep1 addViewAnimation:snapViewAnimation11 forView:self.pointerContainerView];
        
        HLSAnimation *snapAnimation = [HLSAnimation animationWithAnimationStep:snapAnimationStep1];
        snapAnimation.tag = @"snap";
        snapAnimation.lockingUI = YES;
        snapAnimation.delegate = self;
        snapAnimation.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:index],
                                  @"targetIndex", nil];
        [snapAnimation playAnimated:YES];
    }
    else {
        if (m_selectedIndex != index) {
            if (CGRectContainsPoint(self.pointerContainerView.frame, point)) {
                m_selectedIndex = index;
            }
            else {
                m_selectedIndex = [self indexForXPos:self.pointerContainerView.center.x];
            }
            
            [self showElementViewAtIndex:m_selectedIndex selected:YES];
            
            if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
                [self.delegate cursor:self didMoveToIndex:m_selectedIndex];
            }
        }
        
        m_holding = NO;
        m_dragging = NO;
        m_moved = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(cursor:didTouchUpNearIndex:)]) {
        [self.delegate cursor:self didTouchUpNearIndex:index];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    m_holding = NO;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (! m_viewsCreated) {
        return;
    }
    
    if ([animation.tag isEqualToString:@"move"]) {
        m_moving = YES;
        m_moved = YES;
        
        [self showElementViewAtIndex:m_selectedIndex selected:NO];
        
        // The selected index is only updated after the pointer has reached its destination, i.e. at the end of
        // the animation
        if ([self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
            [self.delegate cursor:self didMoveFromIndex:m_selectedIndex];
        }
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"move"]) {
        // If the finger has been released during the move animation, update the selected index and notify
        if (! m_holding) {
            m_selectedIndex = [[animation.userInfo objectForKey:@"targetIndex"] unsignedIntegerValue];
            
            [self showElementViewAtIndex:m_selectedIndex selected:YES];
            
            if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
                [self.delegate cursor:self didMoveToIndex:m_selectedIndex];
            }
        }
        
        m_moving = NO;
    }
    else if ([animation.tag isEqualToString:@"snap"]) {
        m_selectedIndex = [[animation.userInfo objectForKey:@"targetIndex"] unsignedIntegerValue];
        
        [self showElementViewAtIndex:m_selectedIndex selected:YES];
        
        if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
            [self.delegate cursor:self didMoveToIndex:m_selectedIndex];
        }
        
        m_holding = NO;
        m_dragging = NO;
        m_moved = NO;
    }
}

@end
