//
//  UIViewController+HLSViewBinding.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

@interface UIViewController (HLSViewBinding)

- (void)refreshBindings;

- (BOOL)checkDisplayedValuesWithError:(NSError **)pError;

- (BOOL)updateModelWithError:(NSError **)pError;

@end
