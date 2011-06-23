//
//  HLSStripContainerView.h
//  nut
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

// Remark: Strips can never overlap, even when they are moved. This way, at most two strips can be merged at any time

// Forward declarations
@protocol HLSStripContainerViewDelegate;

/**
 * Designated initializer: initWithFrame:
 */
@interface HLSStripContainerView : UIView {
@private
    NSUInteger m_numberOfUnits;
    NSUInteger m_maximumNumberOfStrips;
    BOOL m_enabled;
}

/**
 * Create a strip between the specified positions if there is enough room left. If this is not the case, the strip
 * is not created, except if forced is set to YES. In this case, the strip will take the available space in
 * begin / end direction. Note that it still won't be created if it completely overlaps with an existing strip
 */
- (void)addStripWithBeginPosition:(NSUInteger)beginPosition endPosition:(NSUInteger)endPosition forced:(BOOL)forced;

/**
 * Add a strip, trying to center it at the specified position. If a strip already exists at this position, no other strip
 * is added. If no strip exists, then a new strip with the specified length is created if it fits in. If possible, this
 * strip is centered at position. If no room is available for the specified length, then the strip is not created,
 * except if forced is set to YES (in which case it will take the available space)
 */
- (void)addStripAroundPosition:(NSUInteger)position length:(NSUInteger)length forced:(BOOL)forced;

/**
 * Split a strip at some position. If no strip exists at this position, does nothing.
 */
- (void)splitStripAtPosition:(NSUInteger)position;

/**
 * Delete any strip lying at the specified position. No-op if no strip exists at this position or if it corresponds to
 * two strips (i.e. where two neighbouring strips meet)
 */
- (void)deleteStripAtPosition:(NSUInteger)position;

/**
 * Delete the strip with the specified index (if it exists)
 */
- (void)deleteStripWithIndex:(NSUInteger)index;

/**
 * Number of units which are used to define strips (and to which strips will snap); can be changed on the fly, which
 * will trigger a scale
 */
@property (nonatomic, assign) NSUInteger numberOfUnits;

/**
 * Maximum number of strips which can be created
 */
@property (nonatomic, assign) NSUInteger maximumNumberOfStrips;

/**
 * If set to YES, then the strip view cannot be modified using gestures, only programmatically. Useful to show stripes
 * in read-only mode
 */
@property (nonatomic, assign) BOOL enabled;

@end

@protocol HLSStripContainerViewDelegate <NSObject>

/**
 * A strip could be not be added
 */
- (void)stripContainerViewFailedToAddStrip:(HLSStripContainerView *)stripContainerView;

/**
 * Called right before two strips are merged. Return NO if you do not want the merge to happen, in which case rollback
 * will occur
 */
- (BOOL)stripContainerViewShouldMergeStrips:(HLSStripContainerView *)stripContainerView;

@end
