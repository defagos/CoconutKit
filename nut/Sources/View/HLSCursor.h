//
//  HLSCursor.h
//  nut
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// TODO: Gestion du selected dans les méthodes de datasource
// TODO: Optimize respondsToSelector calls
// TODO: Exemple mélangeant les deux approches custom view (pour l'él. sélectionné) et label

// Forward declarations
@protocol HLSCursorDataSource;
@protocol HLSCursorDelegate;

/**
 * Designated initializer: initWithFrame:
 */
@interface HLSCursor : UIView {
@private
    NSArray *m_elementViews;
    CGFloat m_spacing;
    UIView *m_pointerView;
    CGSize m_pointerViewTopLeftOffset;
    CGSize m_pointerViewBottomRightOffset;
    CGFloat m_xPos;
    BOOL m_dragging;
    BOOL m_clicked;
    BOOL m_grabbed;
    BOOL m_viewsCreated;
    NSUInteger m_initialIndex;
    id<HLSCursorDataSource> m_dataSource;
    id<HLSCursorDelegate> m_delegate;
}

/**
 * Spacing between element views (default is 20 px)
 */
@property (nonatomic, assign) CGFloat spacing;

/**
 * Can be programatically set or using a xib. If nil, the default pointer is used. Should be stretchable so that it
 * can accomodate any element size
 */
@property (nonatomic, retain) IBOutlet UIView *pointerView;

/**
 * Pointer view offset around an element view. Use them to make the pointer rectangle larger or smaller around the element
 * views
 */
@property (nonatomic, assign) CGSize pointerViewTopLeftOffset;              // Default is (-10px, -10px)
@property (nonatomic, assign) CGSize pointerViewBottomRightOffset;          // Default is (10px, 10px)

- (NSUInteger)selectedIndex;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@property (nonatomic, retain) id<HLSCursorDataSource> dataSource;
@property (nonatomic, assign) id<HLSCursorDelegate> delegate;

@end

@protocol HLSCursorDataSource <NSObject>

@required
- (NSUInteger)numberOfElementsForCursor:(HLSCursor *)cursor;

@optional
// Fully customized by specifying a view
- (UIView *)cursor:(HLSCursor *)cursor viewAtIndex:(NSUInteger)index selected:(BOOL)selected;

// Less customization, but no xib needed
- (NSString *)cursor:(HLSCursor *)cursor titleAtIndex:(NSUInteger)index;
- (UIFont *)cursor:(HLSCursor *)cursor fontAtIndex:(NSUInteger)index selected:(BOOL)selected;                   // if not implemented: system font, size 17
- (UIColor *)cursor:(HLSCursor *)cursor textColorAtIndex:(NSUInteger)index selected:(BOOL)selected;             // if not implemented: invert background color
- (UIColor *)cursor:(HLSCursor *)cursor shadowColorAtIndex:(NSUInteger)index selected:(BOOL)selected;           // none if not implemented
- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected;             // top-shadow if not implemented, i.e. CGSizeMake(0, -1)

@end

@protocol HLSCursorDelegate <NSObject>

@optional
- (void)cursor:(HLSCursor *)cursor didSelectIndex:(NSUInteger)index;

@end
