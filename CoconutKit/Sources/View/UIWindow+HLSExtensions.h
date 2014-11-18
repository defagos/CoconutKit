//
//  UIWindow+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 28.10.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

@interface UIWindow (HLSExtensions)

/**
 * Return the active view controller (in general the root view controller of the window or a view controller 
 *ncurrently presented modally)
 */
@property (nonatomic, readonly, strong) UIViewController *activeViewController;

@end
