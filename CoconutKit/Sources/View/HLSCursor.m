//
//  HLSCursor.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSCursor.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSUserInterfaceLock.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "UIView+HLSExtensions.h"

static const CGFloat kCursorDefaultSpacing = 20.f;

@interface HLSCursor ()

- (void)hlsCursorInit;

@property (nonatomic, retain) NSArray *elementViews;
@property (nonatomic, retain) UIView *pointerContainerView;

- (UIView *)elementViewForIndex:(NSUInteger)index selected:(BOOL)selected;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)deselectPreviousIndex;

- (CGFloat)xPosForIndex:(NSUInteger)index;
- (NSUInteger)indexForXPos:(CGFloat)xPos;

- (void)finalizeSelectionForIndex:(NSUInteger)index;

- (void)swapElementViewAtIndex:(NSUInteger)index selected:(BOOL)selected;

- (CGRect)pointerFrameForIndex:(NSUInteger)index;
- (CGRect)pointerFrameForXPos:(CGFloat)xPos;

- (void)endTouches:(NSSet *)touches animated:(BOOL)animated;

- (void)pointerAnimationWillStart:(NSString *)animationID context:(void *)context;
- (void)pointerAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

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
    self.elementViews = nil;
    
    // Very special case here. Cannot use the property since it cannot change the pointer view once set!
    [m_pointerView release];
    
    self.pointerContainerView = nil;
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)hlsCursorInit
{
    self.spacing = kCursorDefaultSpacing;
    self.pointerViewTopLeftOffset = CGSizeMake(-kCursorDefaultSpacing / 2.f, -kCursorDefaultSpacing / 2.f);
    self.pointerViewBottomRightOffset = CGSizeMake(kCursorDefaultSpacing / 2.f, kCursorDefaultSpacing / 2.f);
}

#pragma mark Accessors and mutators

@synthesize elementViews = m_elementViews;

@synthesize spacing = m_spacing;

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
        self.elementViews = [NSArray array];
        
        // Check the data source
        NSUInteger nbrElements = [self.dataSource numberOfElementsForCursor:self];
        if (nbrElements == 0) {
            HLSLoggerError(@"Cursor data source is empty");
            return;
        }
        
        // Fill with views generated from the data source
        for (NSInteger index = 0; index < nbrElements; ++index) {
            UIView *elementView = [self elementViewForIndex:index selected:NO];
            [self addSubview:elementView];
            self.elementViews = [self.elementViews arrayByAddingObject:elementView];            
        }
    }
        
    // Calculate the needed total width
    CGFloat totalWidth = 0.f;
    for (UIView *elementView in self.elementViews) {
        totalWidth += elementView.frame.size.width + self.spacing;
    }
    totalWidth += - self.spacing                                        /* one too much; remove */ 
        + floatmax(0.f, -self.pointerViewTopLeftOffset.width)           /* pointer must fit left if larger than element views */
        + floatmax(0.f, self.pointerViewBottomRightOffset.width);       /* pointer must fit right if larger than element views */
    
    // Adjust individual frames so that the element views are centered within the available frame; warn if too large (will still
    // be centered)
    CGFloat xPos = floorf(fabsf(self.frame.size.width - totalWidth) / 2.f) + floatmax(0.f, -self.pointerViewTopLeftOffset.width);
    if (floatgt(totalWidth, self.frame.size.width)) {
        HLSLoggerWarn(@"Cursor frame not wide enough");
        xPos = -xPos;
    }
    for (UIView *elementView in self.elementViews) {
        // Centered in main frame
        elementView.frame = CGRectMake(xPos, 
                                       floorf((self.frame.size.height - elementView.frame.size.height) / 2.f),
                                       elementView.frame.size.width, 
                                       elementView.frame.size.height);
        xPos += elementView.frame.size.width + self.spacing;
        
        // Check if element view (including cursor if larger) fits vertically (at the top, respectively at the bottom)
        if (floatgt(elementView.frame.size.height / 2.f + floatmax(0.f, -self.pointerViewTopLeftOffset.height), self.frame.size.height / 2.f)
            || floatgt(elementView.frame.size.height / 2.f + floatmax(0.f, self.pointerViewBottomRightOffset.height), self.frame.size.height / 2.f)) {
            HLSLoggerWarn(@"Cursor frame not tall enough");
        }
    }
    
    if (! m_viewsCreated) {
        // If no custom pointer view specified, create a default one
        if (! self.pointerView) {
            UIImage *pointerImage = [UIImage imageNamed:@"CoconutKit-resources.bundle/CursorDefaultPointer.png"];
            UIImageView *imageView = [[[UIImageView alloc] initWithImage:pointerImage] autorelease];
            imageView.contentStretch = CGRectMake(0.5f, 
                                                  0.5f, 
                                                  1.f / imageView.frame.size.width, 
                                                  1.f / imageView.frame.size.height);
            self.pointerView = imageView;            
        }
        
        if (m_initialIndex >= [self.elementViews count]) {
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
        
        [self setSelectedIndex:m_initialIndex animated:NO];
    }
    else if (! m_dragging) {
        self.pointerContainerView.frame = [self pointerFrameForIndex:m_selectedIndex];
    }
    
    m_viewsCreated = YES;
}

- (UIView *)elementViewForIndex:(NSUInteger)index selected:(BOOL)selected
{
    // First check if a custom view is used
    if ([self.dataSource respondsToSelector:@selector(cursor:viewAtIndex:selected:)]) {
        // The size must accomodate both the selected and non-selected versions of an element view (i.e. be the largest).
        // To avoid changing the frame of the views we receive, we simply find the rectangle in which both versions fit,
        // then we create a view with this size and we put the view we receive at its center. 
        UIView *elementView = [self.dataSource cursor:self viewAtIndex:index selected:selected];
        UIView *otherElementView = [self.dataSource cursor:self viewAtIndex:index selected:! selected];
        if (elementView && otherElementView) {
            CGSize elementViewSize = elementView.frame.size;
            CGSize otherElementViewSize = otherElementView.frame.size;
            UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0.f, 
                                                                              0.f,
                                                                              floatmax(elementViewSize.width, otherElementViewSize.width), 
                                                                              floatmax(elementViewSize.height, otherElementViewSize.height))]
                                     autorelease];
            containerView.backgroundColor = [UIColor clearColor];
            [containerView addSubview:elementView];
            elementView.center = containerView.center;
            return containerView;
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
        
        return elementLabel;
    }
    
    // Incorrect data source implementation
    HLSLoggerError(@"Cursor data source must either implement cursor:viewAtIndex: or cursor:titleAtIndex:");
    return nil;
}

#pragma mark Pointer management

- (NSUInteger)selectedIndex
{
    return m_selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (m_viewsCreated && [self.elementViews count] > 0 && selectedIndex >= [self.elementViews count]) {
        HLSLoggerWarn(@"Index outside range. Set to last index");
        selectedIndex = [self.elementViews count] - 1;
    }
    
    m_selectedIndex = selectedIndex;
    
    if (self.elementViews) {
        if (animated) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationWillStartSelector:@selector(pointerAnimationWillStart:context:)];
            [UIView setAnimationDidStopSelector:@selector(pointerAnimationDidStop:finished:context:)];
            [UIView setAnimationDelegate:self];
        }
        
        self.pointerContainerView.frame = [self pointerFrameForIndex:selectedIndex];
        
        if (animated) {
            [UIView commitAnimations];
        }
        else {
            [self finalizeSelectionForIndex:selectedIndex];
        }        
    }
    
    // Will only be used if setSelectedIndex has been called before the views are actually created; not
    // wrapped in an "if (! m_viewsCreated) {...}" test, though. This way, when the cursor is reloaded,
    // the most recently set value is used as initial index
    m_initialIndex = selectedIndex;
}

- (void)deselectPreviousIndex
{
    // Set appearance of previously selected element view to "not selected"
    [self swapElementViewAtIndex:m_selectedIndex selected:NO];
    
    // Notify deselection
    if (m_viewsCreated && [self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
        [self.delegate cursor:self didMoveFromIndex:m_selectedIndex];
    }
}

- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self deselectPreviousIndex];
    [self setSelectedIndex:index animated:animated];
}

- (void)finalizeSelectionForIndex:(NSUInteger)index
{
    [self swapElementViewAtIndex:index selected:YES];
    
    // Send selection event; also sent if the user drags the cursor and release it on the same element that was
    // previously selected. This is needed (and makes sense) since the deselect event is sent as soon the user
    // starts dragging the pointer. Even if we arrive on the same element as before, we must get the corresponding
    // anti-event, i.e. select.
    if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
        [self.delegate cursor:self didMoveToIndex:index];
    }
}

- (void)swapElementViewAtIndex:(NSUInteger)index selected:(BOOL)selected
{
    if ([self.elementViews count] != 0) {
        // Sanitize input
        if (index >= [self.elementViews count]) {
            index = 0;
        }
        
        // Swap selected element view with selected version of it
        UIView *elementView = [self.elementViews objectAtIndex:index];
        UIView *newElementView = [self elementViewForIndex:index selected:selected];
        newElementView.frame = elementView.frame;
        [self insertSubview:newElementView belowSubview:elementView];
        [elementView removeFromSuperview];
        NSMutableArray *mutableElementViews = [NSMutableArray arrayWithArray:self.elementViews];
        [mutableElementViews replaceObjectAtIndex:index withObject:newElementView];
        self.elementViews = [NSArray arrayWithArray:mutableElementViews];
    }
}

- (CGFloat)xPosForIndex:(NSUInteger)index
{
    if ([self.elementViews count] == 0) {
        return 0.f;
    }
    
    if (index >= [self.elementViews count]) {
        HLSLoggerError(@"Invalid index");
        return 0.f;
    }
    
    UIView *elementView = [self.elementViews objectAtIndex:index];
    return elementView.center.x;
}

- (NSUInteger)indexForXPos:(CGFloat)xPos
{
    NSUInteger index = 0;
    for (UIView *elementView in self.elementViews) {
        if (floatge(xPos, elementView.frame.origin.x - self.spacing / 2.f) 
                && floatle(xPos, elementView.frame.origin.x + elementView.frame.size.width + self.spacing / 2.f)) {
            return index;
        }
        ++index;
    }
    
    // No match found; return leftmost or rightmost element view
    UIView *firstElementView = [self.elementViews firstObject_hls];
    if (floatlt(xPos, firstElementView.frame.origin.x - self.spacing / 2.f)) {
        return 0;
    }
    else {
        return [self.elementViews count] - 1;
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
    for (UIView *elementView in self.elementViews) {
        if (floatle(xPos, elementView.center.x)) {
            break;
        }
        ++index;
    }
    
    // Too far on the left; cursor around the first view
    CGRect pointerRect;
    if (index == 0) {
        UIView *firstElementView = [self.elementViews firstObject_hls];
        pointerRect = firstElementView.frame;
    }
    // Too far on the right; cursor around the last view
    else if (index == [self.elementViews count]) {
        UIView *lastElementView = [self.elementViews lastObject];
        pointerRect = lastElementView.frame;
    }
    // Cursor in between views with indices index-1 and index. Interpolate
    else {
        UIView *previousElementView = [self.elementViews objectAtIndex:index - 1];
        UIView *nextElementView = [self.elementViews objectAtIndex:index];
        
        // Linear interpolation
        CGFloat width = ((xPos - nextElementView.center.x) * previousElementView.frame.size.width 
                         + (previousElementView.center.x - xPos) * nextElementView.frame.size.width) / (previousElementView.center.x - nextElementView.center.x);
        CGFloat height = ((xPos - nextElementView.center.x) * previousElementView.frame.size.height 
                          + (previousElementView.center.x - xPos) * nextElementView.frame.size.height) / (previousElementView.center.x - nextElementView.center.x);
        
        pointerRect = CGRectMake(xPos - width / 2.f, 
                                 (self.frame.size.height - height) / 2.f,
                                 width, 
                                 height);
    }
    
    // Adjust the rect according to the offsets to be applied
    pointerRect = CGRectMake(floorf(pointerRect.origin.x + self.pointerViewTopLeftOffset.width),
                             floorf(pointerRect.origin.y + self.pointerViewTopLeftOffset.height),
                             floorf(pointerRect.size.width - self.pointerViewTopLeftOffset.width + self.pointerViewBottomRightOffset.width),
                             floorf(pointerRect.size.height - self.pointerViewTopLeftOffset.height + self.pointerViewBottomRightOffset.height));
    
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
    for (UIView *view in self.elementViews) {
        [view removeFromSuperview];
    }
    self.elementViews = nil;
    
    [self.pointerContainerView removeFromSuperview];
    self.pointerContainerView = nil;
    
    m_selectedIndex = 0;
    m_viewsCreated = NO;
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Might be a click, or a click and hold (which will then trigger a drag event)
    CGPoint point = [[touches anyObject] locationInView:self];
    NSUInteger index = [self indexForXPos:point.x];
    if (index != m_selectedIndex) {
        [self deselectPreviousIndex];
        [self setSelectedIndex:index animated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    if (! m_dragging) {
        m_dragging = YES;
        
        // Check that we are actually grabbing the pointer view
        if (CGRectContainsPoint(self.pointerContainerView.frame, point)) {
            m_grabbed = YES;
            
            // Offset between the point where the finger touches the screen when dragging begins and initial center
            // of the view which will be moved. This makes it possible to compensate this initial offset so that
            // the view frame does not "jump" at the finger location (so that the finger is then at the view center) once
            // the first finger motion is detected. Instead, the frame will nicely follow the finger, even if it was not
            // initially touched at its center
            m_initialDraggingXOffset = point.x - self.pointerContainerView.center.x;
            
            [self swapElementViewAtIndex:m_selectedIndex selected:NO];
            
            if ([self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
                [self.delegate cursor:self didMoveFromIndex:m_selectedIndex];
            }
            
            if ([self.delegate respondsToSelector:@selector(cursorDidStartDragging:)]) {
                [self.delegate cursorDidStartDragging:self];
            }
        }
        else {
            m_grabbed = NO;
        }
    }
    
    if (m_grabbed) {
        CGFloat xPos = point.x - m_initialDraggingXOffset;
        self.pointerContainerView.frame = [self pointerFrameForXPos:xPos];
        if ([self.delegate respondsToSelector:@selector(cursor:didDragNearIndex:)]) {
            [self.delegate cursor:self didDragNearIndex:[self indexForXPos:xPos]];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches animated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endTouches:touches animated:NO];
}

- (void)endTouches:(NSSet *)touches animated:(BOOL)animated
{
    if (m_grabbed) {
        CGPoint point = [[touches anyObject] locationInView:self];
        NSUInteger index = [self indexForXPos:point.x];
        [self setSelectedIndex:index animated:animated];
        
        if ([self.delegate respondsToSelector:@selector(cursorDidStopDragging:)]) {
            [self.delegate cursorDidStopDragging:self];
        }
    }
    
    m_dragging = NO;
    m_grabbed = NO;
}

#pragma mark Animation callbacks

- (void)pointerAnimationWillStart:(NSString *)animationID context:(void *)context
{
    [[HLSUserInterfaceLock sharedUserInterfaceLock] lock];
}

- (void)pointerAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [[HLSUserInterfaceLock sharedUserInterfaceLock] unlock];
    [self finalizeSelectionForIndex:[self selectedIndex]];
}

@end
