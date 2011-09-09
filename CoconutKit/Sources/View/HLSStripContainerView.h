//
//  HLSStripContainerView.h
//  CoconutKit
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSStrip.h"

// Forward declarations
@class HLSStripView;
@protocol HLSStripContainerViewDelegate;

/**
 * A view to which strips (rectangles) can be added, either interactively or progammatically. These strips are defined
 * based on a set of equidistant positions whose number can be set at creation time.
 *
 * The following gestures have been implemented:
 *   - double-tap on an empty location to create a new strip. Strips are created with a default size which can
 *     be freely defined. A strip is created even if not enough space is available (but not if no space is available)
 *     at the tap location
 *   - tap on an existing strip to enter edit mode. Handles are displayed. Tap on one, hold and move the handle
 *     in either direction to resize the strip. Tap again on the strip or on an empty space to leave edit mode. You
 *     can even tap on another strip to enter edit mode for it while leaving edit mode for the previous one.
 *
 * You can create a non-interactive strip container by setting the userInteractionEnabled boolean to NO. In this
 * mode, strips can still be added or removed, but only programmatically.
 *
 * Designated initializer: initWithFrame:
 */
@interface HLSStripContainerView : UIView {
@private
    NSArray *m_allStrips;                   // contains HLSStrip objects (ordered by beginPosition)
    NSMutableDictionary *m_stripToViewMap;  // maps a strip to its corresponding view (HLSStripView)
    NSUInteger m_positions;                 // total number of positions (numbered 0 ... m_positions - 1). Those define m_positions - 1 intervals
    NSUInteger m_interactiveSnapFactor;     // instead of snapping on m_positions - 1 intervals interactively, reduce snap to (m_positions - 1) / m_snapFactor intervals
    NSUInteger m_defaultLength;
    BOOL m_positionsUsed;                   // YES as soon as the value of m_positions has been used (and cannot be changed anymore)
    NSTimeInterval m_touchTimestamp;        // Timestamp at which a touch starts
    BOOL m_draggingLeftHandle;              // YES if dragging the left handle of a strip view
    BOOL m_draggingRightHandle;             // YES if dragging the right handle of a strip view
    HLSStripView *m_movedStripView;         // The view which is being moved or resized (nil if none)
    CGFloat m_handlePreviousXPos;           // Previous position of the handle when grabbed for resizing a strip
    BOOL m_draggingStripView;               // YES if dragging a strip view
    CGFloat m_stripPreviousXPos;            // Previous position of the strip when grabbed and moved
    id<HLSStripContainerViewDelegate> m_delegate;
}

/**
 * Return the array of HLSStrip objects currently displayed in the container. Setting strips this way does not fire
 * the related addition events
 */
- (NSArray *)strips;

/**
 * Set the array of HLSStrip objects to be displayed in the container. Strips should not overlap (if overlapping, only the 
 * one with the lowest begin position will be displayed).
 *
 * Do not update strips if a strip is already being added or removed, the behavior is undefined.
 */
- (void)setStrips:(NSArray *)strips;

/**
 * The number of positions to use (delimit positions - 1 intervals). Default is NSUIntegerMax (highest granularity).
 */
@property (nonatomic, assign) NSUInteger positions;

/**
 * In some cases, you want to be able to measure strips according to some number of positions, but you only want them to
 * snap to a subset of those positions when manipulated interactively. Consider for example a calendar application: You
 * might want to be able to draw strips with minute precision, but you only want the user to define strips in 15
 * minute increments interactively. In this case, interactiveSnapFactor must be 15.
 *
 * As for the iPod / Music application, note that the coarse-grained behavior obtained by setting a factor > 1 affects
 * interactions when the finger is near or on the strip container. For move / resize operations, a finer-grained control 
 * can still be obtained interactively by dragging the finger away while maintaining contact with the screen.
 * 
 * The default value for the snap factor is 1. It must be >= 1 and must divide (positions - 1) (i.e. the number of 
 * intervals) exactly, otherwise it will be fixed to 1. Moreover, this factor is reset when the number of positions
 * is altered.
 */
@property (nonatomic, assign) NSUInteger interactiveSnapFactor;

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
 * Add a strip with the default length. Same behavior as addStripAtPosition:length: otherwise
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
 * If any strip is in edit mode, exit it
 */
- (void)exitEditModeAnimated:(BOOL)animated;

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
 * style is applied. The view returned should exhibit proper stretching behavior
 */
- (UIView *)stripContainerView:(HLSStripContainerView *)stripContainerView isRequestingViewForStrip:(HLSStrip *)strip;

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

/**
 * If this method is implemented, a strip will respond to double tap events and fire this method. This let clients
 * implement their own custom action for double taps
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView didFireActionForStrip:(HLSStrip *)strip;

@end
