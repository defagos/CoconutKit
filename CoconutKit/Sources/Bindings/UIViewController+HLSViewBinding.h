//
//  UIViewController+HLSViewBinding.h
//  mBanking
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

// TODO: Document difference between bindings on views or VCs (views: recursive, unless disabled; view controllers: stop at
//       view controller boundaries)

@interface UIViewController (HLSViewBinding)

- (void)bindToObject:(id)object;

- (void)refreshBindings;

@end
