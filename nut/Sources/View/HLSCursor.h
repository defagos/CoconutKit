//
//  HLSCursor.h
//  nut
//
//  Created by Samuel Défago on 09.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// TODO: Boutons équidistants 
//                 Janvier  Février  Mars  Avril  Mai  ...
//    et non       Janvier   Février   Mars      Avril     Mai ...

// Forward declarations
@protocol HLSCursorDataSource;
@protocol HLSCursorDelegate;

/**
 * Designated initializer: initWithFrame:
 */
@interface HLSCursor : UIView {
@private
    CGFloat m_spacing;
    UIImage *m_highlightImage;
    CGRect m_highlightContentStretch;
    NSUInteger m_selectedIndex;
    id<HLSCursorDataSource> m_dataSource;
    id<HLSCursorDelegate> m_delegate;
}

@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, retain) UIImage *highlightImage;
@property (nonatomic, assign) CGRect highlightContentStretch;

@property (nonatomic, assign) NSUInteger selectedIndex;

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
- (CGSize)cursor:(HLSCursor *)cursor shadowOffsetAtIndex:(NSUInteger)index selected:(BOOL)selected;             // top-shadow if not implemented

@end

@protocol HLSCursorDelegate <NSObject>

@optional
- (void)cursor:(HLSCursor *)cursor didSelectIndex:(NSUInteger)index;

@end
