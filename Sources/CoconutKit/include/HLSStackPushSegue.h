//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "HLSTransition.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The segue identifier reserved for setting the root view controller of a stack ('hls_root')
 */
OBJC_EXPORT NSString * const HLSStackRootSegueIdentifier;

/**
 * Segue class for pushing view controllers into an HLSStackController when using storyboards. The source
 * view controller can implement the -prepareForSegue:sender: method to further customize transition
 * properties, e.g. the transition class. For predefined transition classes, convenience classes have
 * been defined at the end of this file
 *
 * Each HLSStackController dropped onto a storyboard must be connected to its root view controller using
 * a segue with the identifier 'hls_root'. To push a view controller B onto another one A already in the 
 * stack, connect A with B using an HLSStackPushSegue
 *
 * To pop view controllers, implement a method with the following signature:
 *   - (IBAction)methodName:(UIStoryboardSegue *)unwindSegue
 * in the target view controller to pop to. Then bind a control of the view controller to pop from to the
 * Exit icon, and select this method. In the method, call
 *    [self.stackController popToViewController:self animated:animated];
 * to perform the actual pop.
 */
@interface HLSStackPushSegue : UIStoryboardSegue

/**
 * Push animation style
 * Default value is HLSTransitionNone
 */
@property (nonatomic, nullable) Class transitionClass;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic) NSTimeInterval duration;

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, getter=isAnimated) BOOL animated;

@end

/**
 * Convenience class to define subclasses associated with predefined transition classes. Subclass and implement
 * the designated initializer by providing a transition class. The source view controller can implement the 
 * -prepareForSegue:sender: method to further customize transition properties, e.g. the animation duration
 *
 * This class can be used as segue class in storyboards (in which case no transition animation is performed)
 */
@interface HLSStackPushStandardSegue : UIStoryboardSegue

/**
 * Subclasses must override -initWithIdentifier:source:destination:, calling the following method in their implementation
 * (passing it the transition class to use)
 */
- (instancetype)initWithIdentifier:(nullable NSString *)identifier
                            source:(UIViewController *)source
                       destination:(UIViewController *)destination
                   transitionClass:(nullable Class)transitionClass NS_DESIGNATED_INITIALIZER;

/**
 * Push animation style
 */
@property (nonatomic, readonly, nullable) Class transitionClass;

/**
 * Push animation duration
 * Default is kAnimationTransitionDefaultDuration
 */
@property (nonatomic) NSTimeInterval duration;

/**
 * Animated transition
 * Default is YES
 */
@property (nonatomic, getter=isAnimated) BOOL animated;

@end

/**
 * Segue classes defined for all built-in CoconutKit transition classes. The source view controller 
 * can implement the -prepareForSegue:sender: method to further customize transition properties, e.g.
 * the animation duration
 */

@interface HLSStackCoverFromBottomSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromBottomLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromBottomRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromBottomPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromLeftPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromRightPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopLeftPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromTopRightPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromBottomLeftPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCoverFromBottomRightPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFadeInSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFadeInPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackCrossDissolveSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromBottomSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromTopSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromBottomFadeInSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromTopFadeInSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromLeftFadeInSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushFromRightFadeInSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushToBackFromBottomSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushToBackFromTopSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushToBackFromLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackPushToBackFromRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlowFromBottomSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlowFromTopSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlowFromLeftSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlowFromRightSegue : HLSStackPushStandardSegue
@end

@interface HLSStackEmergeFromCenterSegue : HLSStackPushStandardSegue
@end

@interface HLSStackEmergeFromCenterPushToBackSegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlipVerticallySegue : HLSStackPushStandardSegue
@end

@interface HLSStackFlipHorizontallySegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateHorizontallyFromBottomCounterclockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateHorizontallyFromBottomClockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateHorizontallyFromTopCounterclockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateHorizontallyFromTopClockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateVerticallyFromLeftCounterclockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateVerticallyFromLeftClockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateVerticallyFromRightCounterclockwiseSegue : HLSStackPushStandardSegue
@end

@interface HLSStackRotateVerticallyFromRightClockwiseSegue : HLSStackPushStandardSegue
@end

NS_ASSUME_NONNULL_END
