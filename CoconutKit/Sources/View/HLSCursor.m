//
//  HLSCursor.m
//  CoconutKit
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSCursor.h"

#import "HLSAnimation.h"
#import "HLSLogger.h"
#import "HLSViewAnimationStep.h"
#import "NSArray+HLSExtensions.h"
#import "NSBundle+HLSExtensions.h"
#import "UIImage+HLSExtensions.h"
#import "UIView+HLSViewBindingImplementation.h"
#import "UIView+HLSExtensions.h"

@interface HLSCursor ()

@property (nonatomic, strong) NSArray *elementWrapperViews;
@property (nonatomic, strong) NSArray *elementWrapperViewSizeValues;

@property (nonatomic, strong) UIView *pointerContainerView;         // strong, not an error

@end

@implementation HLSCursor {
@private
    NSUInteger _selectedIndex;
    CGFloat _initialDraggingXOffset;
    BOOL _moved;
    BOOL _moving;
    BOOL _dragging;
    BOOL _holding;
    BOOL _creatingViews;
    BOOL _viewsCreated;
    NSUInteger _initialIndex;
    CGFloat _spacing;
}

#pragma mark Object creation and destruction

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self hlsCursorInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self hlsCursorInit];
    }
    return self;
}

- (void)hlsCursorInit
{
    self.pointerViewTopLeftOffset = CGSizeMake(-10.f, -10.f);
    self.pointerViewBottomRightOffset = CGSizeMake(10.f, 10.f);
    self.animationDuration = 0.2;
}

#pragma mark Accessors and mutators

- (void)setPointerView:(UIView *)pointerView
{
    if (_pointerView) {
        HLSLoggerError(@"Cannot change the pointer view once it has been set");
        return;
    }
    
    _pointerView = pointerView;
}

#pragma mark Layout

- (void)layoutSubviews
{
    // Create subviews views lazily the first time they are needed; not doing this in init allows clients to customize
    // the views before they are displayed
    if (! _viewsCreated) {
        // Create the subview set
        self.elementWrapperViews = @[];
        self.elementWrapperViewSizeValues = @[];
        
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
    CGFloat requiredWidth = fmaxf(-self.pointerViewTopLeftOffset.width, 0.f) + fmaxf(self.pointerViewBottomRightOffset.width, 0.f);
    CGFloat requiredHeight = 0.f;
    for (NSValue *elementWrapperViewSizeValue in self.elementWrapperViewSizeValues) {
        CGSize elementWrapperViewSize = [elementWrapperViewSizeValue CGSizeValue];
        requiredWidth += elementWrapperViewSize.width;
        
        if (isgreater(elementWrapperViewSize.height, requiredHeight)) {
            requiredHeight = elementWrapperViewSize.height;
        }
    }
    requiredHeight += fmaxf(-self.pointerViewTopLeftOffset.height, 0.f) + fmaxf(self.pointerViewBottomRightOffset.height, 0.f);
    
    // Cursor large enough so that everything fits in: Add space between elements
    CGFloat widthScaleFactor = 1.f;
    if (islessequal(requiredWidth, CGRectGetWidth(self.frame))) {
        _spacing = (CGRectGetWidth(self.frame) - requiredWidth) / ([self.elementWrapperViews count] - 1);
    }
    // Not large enough: Scale all views so that they can fit with no space in between
    else {
        widthScaleFactor = CGRectGetWidth(self.frame) / requiredWidth;
        _spacing = 0.f;
    }
    
    // Cursor not tall enough: Scale all views so that they can fit vertically
    CGFloat heightScaleFactor = 1.f;
    if (isgreater(requiredHeight, CGRectGetHeight(self.frame))) {
        heightScaleFactor = CGRectGetHeight(self.frame) / requiredHeight;
    }
    
    // Adjust individual frames so that the element views are centered within the available frame
    CGFloat xPos = fmaxf(-self.pointerViewTopLeftOffset.width, 0.f);
    NSUInteger i = 0;
    for (UIView *elementWrapperView in self.elementWrapperViews) {
        CGSize elementWrapperViewSize = [[self.elementWrapperViewSizeValues objectAtIndex:i] CGSizeValue];
        
        // Centered in main frame
        elementWrapperView.frame = CGRectMake(floorf(xPos),
                                              floorf((CGRectGetHeight(self.frame) - heightScaleFactor * elementWrapperViewSize.height) / 2.f),
                                              widthScaleFactor * elementWrapperViewSize.width,
                                              heightScaleFactor * elementWrapperViewSize.height);
        xPos += CGRectGetWidth(elementWrapperView.frame) + _spacing;
        
        ++i;
    }
    
    if (! _viewsCreated) {
        // If no custom pointer view specified, create a default one
        if (! self.pointerView) {
            UIImage *pointerImage = [UIImage coconutKitImageNamed:@"CursorDefaultPointer.png"];
            
            // Calculate caps so that the tiled area is as close as possible to 1 x 1
            CGFloat horizontalCapInset = floorf((pointerImage.size.width - 1.f) / 2.f);
            CGFloat verticalCapInset = floorf((pointerImage.size.height - 1.f) / 2.f);
            pointerImage = [pointerImage resizableImageWithCapInsets:UIEdgeInsetsMake(verticalCapInset, horizontalCapInset, verticalCapInset, horizontalCapInset)];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:pointerImage];
            self.pointerView = imageView;
        }
        
        if (_initialIndex >= [self.elementWrapperViews count]) {
            _initialIndex = 0;
            HLSLoggerWarn(@"Initial index too large; fixed");
        }
        
        // Create a view to container the pointer view. This avoid issues with transparent pointer views
        self.pointerContainerView = [[UIView alloc] initWithFrame:self.pointerView.bounds];
        self.pointerView.frame = self.pointerContainerView.bounds;
        self.pointerContainerView.backgroundColor = [UIColor clearColor];
        self.pointerContainerView.autoresizesSubviews = YES;
        self.pointerContainerView.exclusiveTouch = YES;
        
        self.pointerView.autoresizingMask = HLSViewAutoresizingAll;
        [self.pointerContainerView addSubview:self.pointerView];
        [self addSubview:self.pointerContainerView];
        
        _creatingViews = YES;
        
        [self setSelectedIndex:_initialIndex animated:NO];
        
        _viewsCreated = YES;
    }
    else if (! _dragging && ! _moving) {
        self.pointerContainerView.frame = [self pointerFrameForIndex:_selectedIndex];
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
            HLSLoggerWarn(@"Empty title string at index %lu", (unsigned long)index);
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
            otherFont = [UIFont systemFontOfSize:17.f];
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
        CGSize titleSize = [title sizeWithAttributes:@{ NSFontAttributeName : font }];
        CGSize otherTitleSize = [title sizeWithAttributes:@{ NSFontAttributeName : otherFont }];
        UILabel *elementLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                                          0.f,
                                                                          fmaxf(titleSize.width, otherTitleSize.width),
                                                                          fmaxf(titleSize.height, otherTitleSize.height))];
        elementLabel.text = title;
        elementLabel.backgroundColor = [UIColor clearColor];
        elementLabel.font = font;
        elementLabel.textColor = textColor;
        elementLabel.shadowColor = shadowColor;
        elementLabel.shadowOffset = shadowOffset;
        elementLabel.textAlignment = NSTextAlignmentCenter;
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
    
    UIView *wrapperView = [[UIView alloc] initWithFrame:CGRectMake(0.f,
                                                                   0.f,
                                                                   fmaxf(CGRectGetWidth(elementView.frame), CGRectGetWidth(selectedElementView.frame)),
                                                                   fmaxf(CGRectGetHeight(elementView.frame), CGRectGetHeight(selectedElementView.frame)))];
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
    return _selectedIndex;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (_creatingViews) {
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
        moveAnimation.userInfo = @{ @"targetIndex" : @(selectedIndex) };
        [moveAnimation playAnimated:animated];
    }
    else {
        // Will only be used if setSelectedIndex has been called before the views are actually created; not
        // wrapped in an "if (! _viewsCreated) {...}" test, though. This way, when the cursor is reloaded,
        // the most recently set value is used as initial index
        _initialIndex = selectedIndex;
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
        if (isgreaterequal(xPos, CGRectGetMinX(elementWrapperView.frame) - _spacing / 2.f)
            && islessequal(xPos, CGRectGetMinX(elementWrapperView.frame) + CGRectGetWidth(elementWrapperView.frame) + _spacing / 2.f)) {
            return index;
        }
        ++index;
    }
    
    // No match found; return leftmost or rightmost element view
    UIView *firstElementWrapperView = [self.elementWrapperViews firstObject];
    if (isless(xPos, CGRectGetMinX(firstElementWrapperView.frame) - _spacing / 2.f)) {
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
        if (islessequal(xPos, elementWrapperView.center.x)) {
            break;
        }
        ++index;
    }
    
    // Too far on the left; cursor around the first view
    CGRect pointerRect;
    if (index == 0) {
        UIView *firstElementWrapperView = [self.elementWrapperViews firstObject];
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
    
    _selectedIndex = 0;
    _viewsCreated = NO;
}

#pragma mark Touch events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _holding = YES;
    
    CGPoint point = [[touches anyObject] locationInView:self];
    NSUInteger index = [self indexForXPos:point.x];
    
    if ([self.delegate respondsToSelector:@selector(cursor:didTouchDownNearIndex:)]) {
        [self.delegate cursor:self didTouchDownNearIndex:index];
    }
    
    if (index != _selectedIndex) {
        [self setSelectedIndex:index animated:YES];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    
    // Start dragging
    if (! _dragging) {
        // Check that we are actually grabbing the pointer view
        if (CGRectContainsPoint(self.pointerContainerView.frame, point)) {
            _dragging = YES;
            
            // Offset between the point where the finger touches the screen when dragging begins and initial center
            // of the view which will be moved. This makes it possible to compensate this initial offset so that
            // the view frame does not "jump" at the finger location (so that the finger is then at the view center) once
            // the first finger motion is detected. Instead, the frame will nicely follow the finger, even if it was not
            // initially touched at its center
            _initialDraggingXOffset = point.x - self.pointerContainerView.center.x;
            
            [self showElementViewAtIndex:_selectedIndex selected:NO];
            
            if (! _moved) {
                if ([self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
                    [self.delegate cursor:self didMoveFromIndex:_selectedIndex];
                }                
            }
            
            if ([self.delegate respondsToSelector:@selector(cursorDidStartDragging:nearIndex:)]) {
                [self.delegate cursorDidStartDragging:self nearIndex:_selectedIndex];
            }
        }
    }
    // Dragging
    else {
        CGFloat xPos = point.x - _initialDraggingXOffset;
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
    
    if (_dragging) {
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
        snapAnimation.userInfo = @{ @"targetIndex" : @(index) };
        [snapAnimation playAnimated:YES];
    }
    else {
        if (_selectedIndex != index) {
            if (CGRectContainsPoint(self.pointerContainerView.frame, point)) {
                _selectedIndex = index;
            }
            else {
                _selectedIndex = [self indexForXPos:self.pointerContainerView.center.x];
            }
            [self check:YES update:YES withInputValue:@(_selectedIndex) error:NULL];
            
            [self showElementViewAtIndex:_selectedIndex selected:YES];
            
            if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
                [self.delegate cursor:self didMoveToIndex:_selectedIndex];
            }
        }
        
        _holding = NO;
        _dragging = NO;
        _moved = NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(cursor:didTouchUpNearIndex:)]) {
        [self.delegate cursor:self didTouchUpNearIndex:index];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _holding = NO;
}

#pragma mark HLSAnimationDelegate protocol implementation

- (void)animationWillStart:(HLSAnimation *)animation animated:(BOOL)animated
{
    if (! _viewsCreated) {
        return;
    }
    
    if ([animation.tag isEqualToString:@"move"]) {
        _moving = YES;
        _moved = YES;
        
        [self showElementViewAtIndex:_selectedIndex selected:NO];
        
        // The selected index is only updated after the pointer has reached its destination, i.e. at the end of
        // the animation
        if ([self.delegate respondsToSelector:@selector(cursor:didMoveFromIndex:)]) {
            [self.delegate cursor:self didMoveFromIndex:_selectedIndex];
        }
    }
}

- (void)animationDidStop:(HLSAnimation *)animation animated:(BOOL)animated
{
    if ([animation.tag isEqualToString:@"move"]) {
        // If the finger has been released during the move animation, update the selected index and notify
        if (! _holding) {
            _selectedIndex = [[animation.userInfo objectForKey:@"targetIndex"] unsignedIntegerValue];
            [self check:YES update:YES withInputValue:@(_selectedIndex) error:NULL];
            
            [self showElementViewAtIndex:_selectedIndex selected:YES];
            
            if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
                [self.delegate cursor:self didMoveToIndex:_selectedIndex];
            }
        }
        
        _moving = NO;
    }
    else if ([animation.tag isEqualToString:@"snap"]) {
        _selectedIndex = [[animation.userInfo objectForKey:@"targetIndex"] unsignedIntegerValue];
        [self check:YES update:YES withInputValue:@(_selectedIndex) error:NULL];
        
        [self showElementViewAtIndex:_selectedIndex selected:YES];
        
        if ([self.delegate respondsToSelector:@selector(cursor:didMoveToIndex:)]) {
            [self.delegate cursor:self didMoveToIndex:_selectedIndex];
        }
        
        _holding = NO;
        _dragging = NO;
        _moved = NO;
    }
}

#pragma mark HLSViewBindingImplementation protocol implementation

+ (NSArray *)supportedBindingClasses
{
    return @[[NSNumber class]];
}

- (void)updateViewWithValue:(id)value animated:(BOOL)animated
{
    [self setSelectedIndex:[value unsignedIntegerValue] animated:animated];
}

- (id)inputValueWithClass:(Class)inputClass
{
    return @(self.selectedIndex);
}

@end
