//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Convenience methods on UIViewController. Do nothing if the view controller view is not loaded
 */
@interface UIViewController (HLSViewBinding)

/**
 * Update the values displayed within the view controller view hierarchy, stopping at view controller boundaries.
 * Successfully resolved binding information is not resolved again. If animated is set to YES, the change is made 
 * animated (provided the views support animated updates), otherwise no animation takes place
 */
- (void)updateBoundViewHierarchyAnimated:(BOOL)animated;

/**
 * Same as -updateBoundViewHierarchyAnimated:, but each view is animated according to the its bindUpdateAnimated
 * setting
 */
- (void)updateBoundViewHierarchy;

/**
 * Check the value displayed within the view controller view hierarchy, stopping at view controller boundaries. 
 * Errors are individually reported to the validation delegate, and chained as a single error returned to the 
 * caller as well. The method returns YES iff all operations have been successful
 */
- (BOOL)checkBoundViewHierarchyWithError:(out NSError *__autoreleasing *)pError;

@end

NS_ASSUME_NONNULL_END
