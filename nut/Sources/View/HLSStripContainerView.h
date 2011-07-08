//
//  HLSStripContainerView.h
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// TODO: Use strip identifiers? Returning them when strips are added / removed. This would then offer an opaque handle
//       to get the strip itself without having to return the rectangular view. Well, maybe that's too much
// Remark: Strips must never overlap, even when they are moved (and their distance must be at least 1 unit if they
//         have the same type, otherwise merge will occur). At most two strips can be merged at any time

#import "HLSStrip.h"

// Forward declarations
@class HLSStripView;
@protocol HLSStripContainerViewDelegate;

/**
 * A view to which strips (rectangles) can be added, either interactively or progammatically. These strips snap to
 * equidistant positions whose number can be set at creation time.
 *
 * TODO: More documentation
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSStripContainerView : UIView {
@private
    NSArray *m_allStrips;                   // contains HLSStrip objects (ordered by beginPosition)
    NSMutableDictionary *m_stripToViewMap;  // maps a strip to its corresponding view (HLSStripView)
    NSUInteger m_positions;                 // total number of positions (numbered 0 ... m_positions - 1)
    NSUInteger m_defaultLength;
    BOOL m_positionsUsed;                   // YES as soon as the value of m_positions has been used (and cannot be changed anymore)
    BOOL m_enabled;
    BOOL m_draggingLeftHandle;              // YES if dragging the left handle of a strip view
    BOOL m_draggingRightHandle;             // YES if dragging the right handle of a strip view
    HLSStripView *m_movedStripView;         // The view which is being moved or resized (nil if none)
    CGFloat m_handlePreviousXPos;           // Previous position of the handle when grabbed for resizing a strip
    BOOL m_stripJustMadeLarger;             // When a stripped is moved or resized, stores in which direction the handle is moved
    id<HLSStripContainerViewDelegate> m_delegate;
}

/**
 * Return the array of HLSStrip objects currently displayed in the container. Setting strips this way does not fire
 * the related addition events
 */
- (NSArray *)strips;

/**
 * Set the array of HLSStrip objects to be displayed in the container. Strips should not overlap (if overlapping, only the 
 * one with the lowest begin position will be displayed)
 */
- (void)setStrips:(NSArray *)strips;

/**
 * The number of positions to use. Default is NSUIntegerMax (highest granularity).
 * This value cannot be altered once the container view has used it, you should therefore set it as soon as possible
 * (ideally right after creation)
 */
@property (nonatomic, assign) NSUInteger positions;

/**
 * The default length of strips when added interactively or using addStripAtPosition:. Reset to 1/10th of the number of
 * (positions - 1) when positions is changed
 */
@property (nonatomic, assign) NSUInteger defaultLength;

/**
 * Add a strip with the specified length, trying to center it at the specified position. If a strip already exists at
 * this position, nothing happens. If there is not enough space for the complete strip to fit, then all available
 * space will be filled.
 * The method returns YES iff a strip can be added (use the stripContainerView:didAddStrip: delegate method to
 * know when this is done).
 */
- (BOOL)addStripAtPosition:(NSUInteger)position length:(NSUInteger)length animated:(BOOL)animated;

/**
 * Add a strip with the default length. Same behaviour as addStripAtPosition:length: otherwise
 */
- (BOOL)addStripAtPosition:(NSUInteger)position animated:(BOOL)animated;

/**
 * Split a strip into two strips at some position. If no strip exists at this position, this method does nothing.
 * The method returns YES iff a strip could be splitted.
 */
- (BOOL)splitStripAtPosition:(NSUInteger)position animated:(BOOL)animated;

/**
 * Delete any strip lying at the specified position. The method in general deletes one strip, except if position
 * is where two neighbouring strips meet (in which case two strips will be deleted)
 * The method returns YES iff at least one strip could be deleted.
 */
- (BOOL)deleteStripsAtPosition:(NSUInteger)position animated:(BOOL)animated;

/**
 * Delete the strip with the specified index (if it exists)
 * The method returns YES iff the strip could be deleted.
 */
- (BOOL)deleteStripWithIndex:(NSUInteger)index animated:(BOOL)animated;

/**
 * Delete the specified strip (if it exists)
 * The method returns YES iff the strip could be deleted.
 */
- (BOOL)deleteStrip:(HLSStrip *)strip animated:(BOOL)animated;

/**
 * Move the strip with the specified index to a position and change its length.
 * The method returns YES iff the strip could be moved (no overlap, must not cross other strips)
 */
- (BOOL)moveStripWithIndex:(NSUInteger)index newPosition:(NSUInteger)newPosition newLength:(NSUInteger)newLength animated:(BOOL)animated;

/**
 * Move the specified strip to a position and change its length.
 * The method returns YES iff the strip could be moved.
 */
- (BOOL)moveStrip:(HLSStrip *)strip newPosition:(NSUInteger)newPosition newLength:(NSUInteger)newLength animated:(BOOL)animated;

/**
 * Clear the strip container view area, without generating any deletion events. Useful if you reuse the same container
 * view and you need to start again from scratch
 */
- (void)clear;

/**
 * If set to YES, then the strip view cannot be modified using gestures, only programmatically. Useful to show strips
 * in read-only mode
 */
@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, assign) id<HLSStripContainerViewDelegate> delegate;

@end

@protocol HLSStripContainerViewDelegate <NSObject>

@optional

/**
 * Called right before a new strip is added. Return NO to cancel
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldAddStrip:(HLSStrip *)strip;

/**
 * Called when a strip view is created. Return the view to be used. If not implemented or if returning nil, a default 
 * style is applied. The view returned should exhibit proper stretching behaviour
 */
- (UIView *)stripContainerViewIsRequestingViewForStrip:(HLSStrip *)strip;

/**
 * Called after a new strip has been added
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didAddStrip:(HLSStrip *)strip animated:(BOOL)animated;

/**
 * Called right before a strip is split. Return NO to cancel
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldSplitStrip:(HLSStrip *)strip;

/**
 * Called right before a strip is deleted. Return NO to cancel
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldDeleteStrip:(HLSStrip *)strip;

/**
 * Called when a strip is about to be moved or resized
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView willMoveStrip:(HLSStrip *)strip animated:(BOOL)animated;

/**
 * Called after a strip has been moved or resized
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didMoveStrip:(HLSStrip *)strip animated:(BOOL)animated;

/**
 * Called right before two strips are merged. Return NO if to cancel, in which case the strips will be rollbacked
 * to their original position
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldMergeStrip:(HLSStrip *)strip1 withStrip:(HLSStrip *)strip2;

/**
 * Called when a strip is about to enter edit mode. Return NO to prevent resizing
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldEnterEditModeForStrip:(HLSStrip *)strip;

/**
 * Called when edit mode has been entered
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didEnterEditModeForStrip:(HLSStrip *)strip;

/**
 * Called when edit mode has exited
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didExitEditModeForStrip:(HLSStrip *)strip;

@end
