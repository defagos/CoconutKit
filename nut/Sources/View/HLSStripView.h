//
//  HLSStripView.h
//  nut
//
//  Created by Samuel Défago on 06.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStrip.h"

// Forward declarations
@protocol HLSStripViewDelegate;

/**
 * The view corresponding to a strip. Built around a customizable view, it provides an edit mode allowing to resize
 * a strip using handles appearing at the left and right of the strip itself.
 *
 * This class solely exists for implementation purposes and is not public.
 *
 * Designated initialier: initWithStrip:contentView:
 */
@interface HLSStripView : UIView {
@private
    HLSStrip *m_strip;
    UIView *m_contentView;
    CGRect m_contentFrameInParent;
    UIView *m_leftHandleView;
    UIView *m_rightHandleView;
    UILabel *m_leftLabel;
    UILabel *m_rightLabel;
    BOOL m_edited;
    BOOL m_draggingLeftHandle;
    BOOL m_draggingRightHandle;
    HLSAnimation *m_editModeAnimation;
    id<HLSStripViewDelegate> m_delegate;
}

- (id)initWithStrip:(HLSStrip *)strip contentView:(UIView *)contentView;

/**
 * The strip attached to the strip view
 */
@property (nonatomic, retain) HLSStrip *strip;

/**
 * The contents displayed inside the strip. Will be surrounded by handles when the strip enters edit mode
 */
@property (nonatomic, readonly, retain) IBOutlet UIView *contentView;

/**
 * The strip frame where it must appear in the parent view coordinate system
 */
@property (nonatomic, assign) CGRect contentFrameInParent;

/**
 * The handle frames as they appear in the parent view coordinate system
 */
- (CGRect)leftHandleFrameInParent;
- (CGRect)rightHandleFrameInParent;

/**
 * The handle views, or nil when not visible
 */
@property (nonatomic, readonly, retain) UIView *leftHandleView;
@property (nonatomic, readonly, retain) UIView *rightHandleView;

/**
 * Returns YES when the strip view is in edit mode
 */
@property (nonatomic, assign, getter=isEdited) BOOL edited;

@property (nonatomic, assign) id<HLSStripViewDelegate> delegate;

/**
 * Toggle edit mode on or off
 */
- (void)enterEditModeAnimated:(BOOL)animated;
- (void)exitEditModeAnimated:(BOOL)animated;

@end

@protocol HLSStripViewDelegate <NSObject>

@required

- (void)stripViewDidResize:(HLSStripView *)stripView;
- (void)stripView:(HLSStripView *)stripView didEnterEditModeAnimated:(BOOL)animated;
- (void)stripView:(HLSStripView *)stripView didExitEditModeAnimated:(BOOL)animated;

@end
