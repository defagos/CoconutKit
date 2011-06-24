//
//  HLSStripContainerView.h
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// TODO: Use strip identifiers? Returning them when strips are added / removed. This would then offer an opaque handle
//       to get the strip itself without having to return the rectangular view. Well, maybe that's too much
// Remark: Strips must never overlap, even when they are moved. This way, at most two strips can be merged at any time

#import "HLSStrip.h"

// Forward declarations
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
    NSArray *m_strips;                      // contains HLSStrip objects (ordered by beginPosition)
    NSUInteger m_positions;                 // total number of positions (numbered 0 ... m_positions - 1)
    NSUInteger m_defaultLength;
    BOOL m_positionsUsed;                   // YES as soon as the value of m_positions has been used (and cannot be changed anymore)
    BOOL m_enabled;
    id<HLSStripContainerViewDelegate> m_delegate;
}

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
 * Add a strip with the the specified length, trying to center it at the specified position. If a strip already exists at
 * this position, nothing happens. If there is not enough space for the complete strip to fit, then all available
 * space will be filled.
 * The method returns YES iff a strip could be added.
 */
- (BOOL)addStripAtPosition:(NSUInteger)position length:(NSUInteger)length;

/**
 * Add a strip with the default length. Same behaviour as addStripAtPosition:length: otherwise
 */
- (BOOL)addStripAtPosition:(NSUInteger)position;

/**
 * Split a strip into two strips at some position. If no strip exists at this position, this method does nothing.
 * The method returns YES iff a strip could be splitted.
 */
- (BOOL)splitStripAtPosition:(NSUInteger)position;

/**
 * Delete any strip lying at the specified position. The method in general deletes one strip, except if position
 * is where two neighbouring strips meet (in which case two strips will be deleted)
 * The method returns YES iff at least one strip could be deleted.
 */
- (BOOL)deleteStripsAtPosition:(NSUInteger)position;

/**
 * Delete the strip with the specified index (if it exists)
 * The method returns YES iff a strip could be deleted.
 */
- (BOOL)deleteStripWithIndex:(NSUInteger)index;

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
 * Called when a split view is created. Return the view to be used (must be properly stretchable). If not implemented or 
 * if returning nil, a default style is applied.
 */
- (UIView *)stripContainerViewIsRequestingViewForStrip:(HLSStrip *)strip;

/**
 * Called after a new strip has been added
 */
- (void)stripContainerView:(HLSStripContainerView *)stripContainerView hasAddedStrip:(HLSStrip *)strip;

/**
 * Called right before a strip is split. Return NO to cancel
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldSplitStrip:(HLSStrip *)strip;

/**
 * Called right before a strip is deleted. Return NO to cancel
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldDeleteStrip:(HLSStrip *)strip;

/**
 * Called right before two strips are merged. Return NO if to cancel, in which case the strips will be rollbacked
 * to their original position
 */
- (BOOL)stripContainerView:(HLSStripContainerView *)stripContainerView shouldMergeStrip:(HLSStrip *)strip1 withStrip:(HLSStrip *)strip2;

@end
