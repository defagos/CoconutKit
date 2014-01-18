//
//  UIViewController+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

// TODO: Document difference between bindings on views or VCs (views: recursive, unless disabled; view controllers: stop at
//       view controller boundaries)

@interface UIViewController (HLSViewBinding)

// If recursive set to YES, display binding information for child view controllers as well
- (void)showBindingDebugOverlayViewRecursive:(BOOL)recursive;

// Document: The object is retained
- (void)bindToObject:(id)object;

- (void)refreshBindingsForced:(BOOL)forced;

@end
