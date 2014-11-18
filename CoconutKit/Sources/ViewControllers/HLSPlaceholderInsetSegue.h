//
//  HLSPlaceholderInsetSegue.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.06.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSTransition.h"

/**
 * The segue identifier prefix reserved for preloading view controllers into a placeholder view controller
 * ('hls_preload_at_index_')
 */
extern NSString * const HLSPlaceholderPreloadSegueIdentifierPrefix;

/**
 * Segue class for setting the inset view controller of an HLSPlaceholderViewController when using storyboards.
 *
 * The source view controller must either be a placeholder view controller, or a view controller already installed
 * as inset view controller of a placeholder view controller. The source view controller can implement the 
 * -prepareForSegue:sender: method to further customize transition properties (index, transition style and duration)
 *
 * A view controller can be preloaded into a placeholder view controllers by binding the placeholder view controller
 * with it using a segue with the reserved identifier 'hls_preload_at_index__N', where N is the index at which the view 
 * controller must be initially loaded. This index must be between 0 and 19, which allows preloading of 20 view 
 * controllers. This should be sufficient: Though a placeholder view controller can hold more than 20 view controllers,
 * this should never occur in practice
 */
@interface HLSPlaceholderInsetSegue : UIStoryboardSegue

/**
 * The placeholder view index which the destination view controller must be displayed in
 * Default value is 0
 */
@property (nonatomic, assign) NSUInteger index;

/**
 * Push animation style
 * Default value is [HLSTransitionNone class]
 */
@property (nonatomic, assign) Class transitionClass;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, assign) BOOL animated;

@end

/**
 * Convenience class to define subclasses associated with predefined transition classes. Subclass and implement
 * the designated initializer by providing a transition class. The source view controller can implement the
 * -prepareForSegue:sender: method to further customize transition properties, e.g. the animation duration
 *
 * This class can be used as segue class in storyboards (in which case no transition animation is performed)
 */
@interface HLSPlaceholderInsetStandardSegue : UIStoryboardSegue

/**
 * Subclasses must override -initWithIdentifier:source:destination:, calling the following method in their implementation
 * (passing it the transition class to use)
 */
- (instancetype)initWithIdentifier:(NSString *)identifier
                            source:(UIViewController *)source
                       destination:(UIViewController *)destination
                   transitionClass:(Class)transitionClass;

/**
 * The placeholder view index which the destination view controller must be displayed in
 * Default value is 0
 */
@property (nonatomic, assign) NSUInteger index;

/**
 * Push animation style
 * Default value is HLSTransitionNone
 */
@property (nonatomic, readonly, assign) Class transitionClass;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic, assign) NSTimeInterval duration;

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, assign) BOOL animated;

@end

/**
 * Segue classes defined for all built-in CoconutKit transition classes. The source view controller
 * can implement the -prepareForSegue:sender: method to further customize transition properties, e.g.
 * the animation duration
 */

@interface HLSPlaceholderCoverFromBottomSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromBottomLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromBottomRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromBottomPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromLeftPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromRightPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopLeftPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromTopRightPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromBottomLeftPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCoverFromBottomRightPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFadeInSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFadeInPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderCrossDissolveSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromBottomSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromTopSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromBottomFadeInSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromTopFadeInSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromLeftFadeInSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushFromRightFadeInSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushToBackFromBottomSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushToBackFromTopSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushToBackFromLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderPushToBackFromRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlowFromBottomSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlowFromTopSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlowFromLeftSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlowFromRightSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderEmergeFromCenterSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderEmergeFromCenterPushToBackSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlipVerticallySegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderFlipHorizontallySegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateHorizontallyFromBottomCounterclockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateHorizontallyFromBottomClockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateHorizontallyFromTopCounterclockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateHorizontallyFromTopClockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateVerticallyFromLeftCounterclockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateVerticallyFromLeftClockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateVerticallyFromRightCounterclockwiseSegue : HLSPlaceholderInsetStandardSegue
@end

@interface HLSPlaceholderRotateVerticallyFromRightClockwiseSegue : HLSPlaceholderInsetStandardSegue
@end
