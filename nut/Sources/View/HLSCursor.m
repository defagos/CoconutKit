//
//  HLSCursor.m
//  nut
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSCursor.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "HLSUserInterfaceLock.h"

static const CGFloat kCursorDefaultSpacing = 20.f;

@interface HLSCursor ()

- (void)initialize;

@property (nonatomic, retain) NSArray *elementViews;
@property (nonatomic, retain) UIView *pointerContainerView;

- (UIView *)elementViewForIndex:(NSUInteger)index selected:(BOOL)selected;

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

- (void)dealloc
{
    self.elementViews = nil;
    self.pointerView = nil;
    self.pointerContainerView = nil;
    self.dataSource = nil;
    
    [super dealloc];
}

- (void)initialize
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
    CGFloat xPos = floorf(fabs(self.frame.size.width - totalWidth) / 2.f);
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
            UIImage *pointerImage = [UIImage imageNamed:@"nut_cursor_default_pointer.png"];
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
        self.pointerContainerView = [[[UIView alloc] initWithFrame:self.pointerView.frame] autorelease];
        self.pointerContainerView.backgroundColor = [UIColor clearColor];
        self.pointerContainerView.autoresizesSubviews = YES;
        self.pointerContainerView.exclusiveTouch = YES;
        
        self.pointerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.pointerContainerView addSubview:self.pointerView];
        [self addSubview:self.pointerContainerView];
        
        [self setSelectedIndex:m_initialIndex animated:NO];
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
    return [self indexForXPos:m_xPos];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{   
    // Set appearance of previously selected element view to "not selected"
    [self swapElementViewAtIndex:[self indexForXPos:m_xPos] selected:NO];
    
    m_xPos = [self xPosForIndex:selectedIndex];
    
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

- (void)finalizeSelectionForIndex:(NSUInteger)index
{
    [self swapElementViewAtIndex:index selected:YES];
    
    // Notify the delegate
    if ([self.delegate respondsToSelector:@selector(cursor:isMovingPointerWithNearestIndex:)]) {
        HLSLoggerDebug(@"Calling cursor:isMovingPointerWithNearestIndex:");
        [self.delegate cursor:self isMovingPointerWithNearestIndex:[self indexForXPos:m_xPos]];
    }
    if ([self.delegate respondsToSelector:@selector(cursor:didSelectIndex:)]) {
        HLSLoggerDebug(@"Calling cursor:didSelectIndex:");
        [self.delegate cursor:self didSelectIndex:index];
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
    UIView *firstElementView = [self.elementViews firstObject];
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
        UIView *firstElementView = [self.elementViews firstObject];
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
    
    m_xPos = 0.f;
    m_viewsCreated = NO;
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If clicking on the pointer, do not select it again. This corresponds to the user grabbing the pointer
    CGPoint pos = [[touches anyObject] locationInView:self];
    if (! CGRectContainsPoint(self.pointerContainerView.frame, pos)) {
        m_clicked = YES;
        [self setSelectedIndex:[self indexForXPos:pos.x] animated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    if (! m_clicked) {
        if (! m_dragging) {
            m_dragging = YES;
            
            // Check that we are actually grabbing the pointer view
            if (CGRectContainsPoint(self.pointerContainerView.frame, pos)) {
                m_grabbed = YES;
                
                NSUInteger index = [self indexForXPos:m_xPos];
                [self swapElementViewAtIndex:index selected:NO];
                
                if ([self.delegate respondsToSelector:@selector(cursorDidStartDragging:)]) {
                    HLSLoggerDebug(@"Calling cursorDidStartDragging:");
                    [self.delegate cursorDidStartDragging:self];
                }
            }
            else {
                m_grabbed = NO;
            }
        }
        
        if (m_grabbed) {
            self.pointerContainerView.frame = [self pointerFrameForXPos:pos.x];
            m_xPos = pos.x;
            NSUInteger index = [self indexForXPos:m_xPos];
            if ([self.delegate respondsToSelector:@selector(cursor:isMovingPointerWithNearestIndex:)]) {
                HLSLoggerDebug(@"Calling cursor:isMovingPointerWithNearestIndex:");
                [self.delegate cursor:self isMovingPointerWithNearestIndex:index];
            }
            
            if ([self.delegate respondsToSelector:@selector(cursor:isDraggingWithNearestIndex:)]) {
                HLSLoggerDebug(@"Calling cursor:isDraggingWithNearestIndex:");
                [self.delegate cursor:self isDraggingWithNearestIndex:index];
            }
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
        CGPoint pos = [[touches anyObject] locationInView:self];
        NSUInteger index = [self indexForXPos:pos.x];
        [self setSelectedIndex:index animated:animated];
        
        if ([self.delegate respondsToSelector:@selector(cursorDidStopDragging:)]) {
            HLSLoggerDebug(@"Calling cursorDidStopDragging:");
            [self.delegate cursorDidStopDragging:self];
        }
    }
    
    m_dragging = NO;
    m_grabbed = NO;
    m_clicked = NO;
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
