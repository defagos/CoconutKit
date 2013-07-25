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

// Document: The object is retained
- (void)bindToObject:(id)object;

- (void)refreshBindings;

@end
