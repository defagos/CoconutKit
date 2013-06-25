//
//  UIView+HLSViewBinding.h
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

// TOOD: Make this header private. Bindings must be defined at the controller level (where both view and model are
//       involved). It is impossible to know where binding must start and stop in the view hierarchy: This follows
//       from the view controller hierarchy

// TODO: Create CoconutKit examples with all cases. Also with @min, @max, etc. keypath operators! Document!

@protocol HLSViewBinding <NSObject>

@optional

/**
 * UIView subclasses can implement this method to perform the logic necessary to update the view using the new 
 * value corresponding to an identified biding. If this method is not implemented, bindings will not be available
 */
- (void)updateViewWithText:(NSString *)text;

/**
 * UIView subclasses can implement this method to return YES if subviews must be updated recursively when the
 * receiver is updated. If not implemented, the default behavior is YES
 */
- (BOOL)updatesSubviewsRecursively;

// TODO: This can be implemented to sync from view to model. Do it for UITextField (implement validation too? Make
//       Core Data bindings a special case)
- (BOOL)updateBoundObjectWithText:(NSString *)text;

@end

@interface UIView (HLSViewBinding) <HLSViewBinding>

/**
 * Bind an object to the specified bind path. This bind path must be a KVC-compliant keypath. Object updates
 * are automatically reflected using KVO. Binds recursively (if enabled) and stops at view controller boundaries
 */
- (void)bindToObject:(id)object;
- (void)unbind;

// TODO: Move to a private which can be accessed from implementation files, but not from outside the framework
- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController;
- (void)refreshBindingsInViewController:(UIViewController *)viewController;
- (void)updateText;

@end
