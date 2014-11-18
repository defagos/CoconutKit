//
//  UIViewController+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

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
- (BOOL)checkBoundViewHierarchyWithError:(NSError *__autoreleasing *)pError;

@end
