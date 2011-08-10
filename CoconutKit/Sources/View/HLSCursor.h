//
//  HLSCursor.h
//  CoconutKit
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

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
 * Cursors using both ways of customization can coexist in the same source file.
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSCursor : UIView {
@private
    NSArray *m_elementViews;
    CGFloat m_spacing;
    UIView *m_pointerView;
    UIView *m_pointerContainerView;
    CGSize m_pointerViewTopLeftOffset;
    CGSize m_pointerViewBottomRightOffset;
    CGFloat m_xPos;
    BOOL m_dragging;
    CGFloat m_initialDraggingXOffset;
    BOOL m_clicked;
    BOOL m_grabbed;
    BOOL m_viewsCreated;
    NSUInteger m_initialIndex;
    id<HLSCursorDataSource> m_dataSource;
    id<HLSCursorDelegate> m_delegate;
}

/**
 * Spacing between elements displayed by the cursor (default is 20 px)
 */
@property (nonatomic, assign) CGFloat spacing;

/**
 * The pointer view, which can either be set programatically or using a xib. If nil, the default pointer will be used.
 * If you use a custom view, be sure it can stretch properly since the pointer view frame will be adjusted depending
 * on the element it is on. In general, your custom pointer view is likely to be transparent so that the element
 * below it can be seen.
 *
 * As soon as the pointer view has been set it cannot be changed anymore.
 */
@property (nonatomic, retain) IBOutlet UIView *pointerView;

/**
 * Pointer view offsets. Use these offsets to make the pointer rectangle larger or smaller than the element it points
 * at. By default the pointer view frame is 10px larger in all directions
 */
@property (nonatomic, assign) CGSize pointerViewTopLeftOffset;              // Default is (-10px, -10px)
@property (nonatomic, assign) CGSize pointerViewBottomRightOffset;          // Default is (10px, 10px)

/**
 * Get the currently selected element. During the time the pointer is moved the selected index is not updated. This value
 * is only updated as soon as the pointer reaches a new element.
 */
- (NSUInteger)selectedIndex;

/**
 * Move the pointer to a specific element. This setter can also be used to set the initially selected element before the
 * cursor is displayed (in this case, the animated parameter is ignored)
 */
- (void)moveToIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Reload the cursor from the data source. The pointer is left at the same index where it was, except if the index
 * is out of range after the reload (in which case the pointer is reset to point on the first element)
 */
- (void)reloadData;

/**
 * Set / get the data source used to fill the cursor with elements
 */
@property (nonatomic, assign) id<HLSCursorDataSource> dataSource;

/**
 * Set / get the cursor delegate receiving the cursor events
 */
@property (nonatomic, assign) id<HLSCursorDelegate> delegate;

@end

@protocol HLSCursorDataSource <NSObject>

@required
// The number of elements to display
- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor;

@optional
// Fully customized by specifying a view. You can use the selected boolean to set a different view for selected and
// non-selected elements
- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected;

// Less customization, but no view is needed. You can use the selected boolean to set different properties for
// selected and non-selected elements
- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index;
- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected;                   // if not implemented or returning nil: system font, size 17
- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected;             // if not implemented or returning nil: invert background color
- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected;           // none if not implemented or returning nil
- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected;             // top-shadow if not implemented or returning kCursorShadowOffsetDefault

@end

@protocol HLSCursorDelegate <NSObject>

@optional
// Triggered when the pointer leaves a selected element at a given index
- (void)cursor:(HLSCursor *)cursor didMoveFromIndex:(NSUInteger)index;

// Triggered when the pointer stops moving, selecting a new element
- (void)cursor:(HLSCursor *)cursor didMoveToIndex:(NSUInteger)index;

// Triggered when the user starts dragging the pointer
- (void)cursorDidStartDragging:(HLSCursor *)cursor;

// Triggered when the user is dragging the pointer. The nearest index is given as parameter
- (void)cursor:(HLSCursor *)cursor didDragNearIndex:(NSUInteger)index;

// Triggered when the user stops dragging the pointer
- (void)cursorDidStopDragging:(HLSCursor *)cursor;

@end
