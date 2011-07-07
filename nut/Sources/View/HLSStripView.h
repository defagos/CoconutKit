//
//  HLSStripView.h
//  nut
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStrip.h"

// Forward declarations
@class HLSStripHandleView;
@protocol HLSStripViewDelegate;

/**
 * The view corresponding to a strip. Built around a customizable view
 *
 * Designated initialier: initWithStrip:view:
 */
@interface HLSStripView : UIView {
@private
    HLSStrip *m_strip;
    HLSStripHandleView *m_leftHandleView;
    HLSStripHandleView *m_rightHandleView;
    UILabel *m_leftLabel;
    UILabel *m_rightLabel;
    BOOL m_edited;
    id<HLSStripViewDelegate> m_delegate;
}

- (id)initWithStrip:(HLSStrip *)strip view:(UIView *)view;

@property (nonatomic, retain) HLSStrip *strip;
@property (nonatomic, assign, getter=isEdited) BOOL edited;
@property (nonatomic, assign) id<HLSStripViewDelegate> delegate;

- (void)setContentFrame:(CGRect)contentFrame;

- (void)enterEditMode;
- (void)exitEditMode;

@end

@protocol HLSStripViewDelegate <NSObject>

@required

- (void)stripViewHasBeenClicked:(HLSStripView *)stripView;

@end
