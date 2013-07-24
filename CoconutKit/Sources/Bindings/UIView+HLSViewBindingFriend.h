//
//  UIView+HLSViewBindingFriend.h
//  CoconutKit
//
//  Created by Samuel Défago on 26.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface UIView (HLSViewBindingFriend)

- (void)bindToObject:(id)object inViewController:(UIViewController *)viewController;
- (void)refreshBindingsInViewController:(UIViewController *)viewController;

@end
