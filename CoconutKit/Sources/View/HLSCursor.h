//
//  HLSCursor.h
//  CoconutKit
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "HLSAnimation.h"
#import "UIView+HLSViewBindingImplementation.h"

// Macros
#define kCursorShadowOffsetDefault      CGSizeMake(0, -1)

// Forward declarations
@protocol HLSCursorDataSource;
@protocol HLSCursorDelegate;

/**
 * A class for creating value cursors, i.e. sets of elements from which one is exactly active at any time. The current 
 * element is identified by a graphical pointer. This pointer can either be moved by clicking another value or by dragging
 * it.
 *
 * Adding a cursor to your application is very easy:
 *   - add a HLSCursor, either programmatically or using Interface Builder
 *   - implement a data source (HLSCursorDataSource protocol) to set the elements to display
 *   - implement a delegate (HLSCursorDelegate protocol) to respond to cursor events
 *
 * The cursor layout is automatically created for you: You just need to set the main cursor frame size, the layout is
 * calculated for you depending on the size of the elements which need to be displayed. During development, if you use the
 * debug version of the library, warnings will be displayed in the console if the frame is too small to display the cursor
 * contents correctly (see HLSLogger for the available logging levels).
 *
 * There are two ways to set the cursor contents. Both can be mixed within the same cursor:
 *   - basic: You just set the text and basic text properties (font, colors, shadows)
 *   - custom: Each element is a view and can be customized using Interface Builder
 * Cursors using both ways of customisation can coexist in the same source file.
 *
 * Remark: If the cursor is placed inside a scroll view, you might need to set canCancelContentTouches on it so that
 *         dragging the pointer view can work as expected
 *
 * Binding support for HLSCursor:
 *   - binds to NSNumber model values
 *   - displays and updates the underlying model value
 *   - can animate updates
 *
 */
@interface HLSCursor : UIView <HLSAnimationDelegate, HLSViewBindingImplementation>

/**
 * The pointer view, which can either be set programmatically or using a xib. If nil, the default pointer will be used.
 * If you use a custom view, be sure it can stretch properly since the pointer view frame will be adjusted depending
 * on the element it is on. In general, your custom pointer view is likely to be transparent so that the element
 * below it can be seen.
 *
 * As soon as the pointer view has been set it cannot be changed anymore.
 */
@property (nonatomic, strong) IBOutlet UIView *pointerView;     // strong, not an error

/**
 * The duration of cursor animations
 *
 * Default is 0.2
 */
@property (nonatomic, assign) NSTimeInterval animationDuration;

/**
 * Pointer view offsets. Use these offsets to make the pointer rectangle larger or smaller than the element it points
 * at
 */
@property (nonatomic, assign) CGSize pointerViewTopLeftOffset;              // Default is (-10px, -10px); set negative values to grow larger
@property (nonatomic, assign) CGSize pointerViewBottomRightOffset;          // Default is (10px, 10px); set negative values to grow larger

/**
 * Get the currently selected element. During the time the pointer is moved the selected index is not updated. This value
 * is only updated as soon as the pointer reaches a new element
 */
- (NSUInteger)selectedIndex;

/**
 * Move the pointer to a specific element. This setter can also be used to set the initially selected element before the
 * cursor is displayed (in this case, the animated parameter is ignored)
 *
 * If the animated property has been set to NO, the animated parameter is ignored
 */
- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Reload the cursor from the data source. The pointer is left at the same index where it was, except if the index
 * is out of range after the reload (in which case the pointer is reset to point on the first element)
 */
- (void)reloadData;

/**
 * Set / get the data source used to fill the cursor with elements
 */
@property (nonatomic, weak) id<HLSCursorDataSource> dataSource;

/**
 * Set / get the cursor delegate receiving the cursor events
 */
@property (nonatomic, weak) id<HLSCursorDelegate> delegate;

@end

@protocol HLSCursorDataSource <NSObject>

@required
// The number of elements to display
- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor;

@optional
// Fully customized by specifying a view. You can use the selected boolean to set a different view for selected and
// non-selected elements
- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected;

// Less customisation, but no view is needed. You can use the selected boolean to set different properties for
// selected and non-selected elements
- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index;
- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected;                   // if not implemented or returning nil: system font, size 17
- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected;             // if not implemented or returning nil: invert background color
- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected;           // none if not implemented or returning nil
- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected;             // top-shadow if not implemented or returning kCursorShadowOffsetDefault

@end

@protocol HLSCursorDelegate <NSObject>

@optional

// Triggered when the user performs starts touching the cursor
- (void)cursor:(HLSCursor *)cursor didTouchDownNearIndex:(NSUInteger)index;

// Triggered when the pointer leaves a selected element at a given index
- (void)cursor:(HLSCursor *)cursor didMoveFromIndex:(NSUInteger)index;

// Triggered when the pointer stops moving, selecting a new element
- (void)cursor:(HLSCursor *)cursor didMoveToIndex:(NSUInteger)index;

// Triggered when the user starts dragging the pointer
- (void)cursorDidStartDragging:(HLSCursor *)cursor nearIndex:(NSUInteger)index;

// Triggered when the user is dragging the pointer. The nearest index is given as parameter
- (void)cursor:(HLSCursor *)cursor didDragNearIndex:(NSUInteger)index;

// Triggered when the user stops dragging the pointer
- (void)cursorDidStopDragging:(HLSCursor *)cursor nearIndex:(NSUInteger)index;

// Triggered when the user stops touching the cursor
- (void)cursor:(HLSCursor *)cursor didTouchUpNearIndex:(NSUInteger)index;

@end
