//
//  UIActionSheet+HLSExtensions.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 24.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

@interface UIActionSheet (HLSExtensions)

/**
 * The object which is showing the action sheet. Can be a UIBarButtonItem, a UIToolbar, a UITabBar
 * or simply a UIView depending on which show... method was called. If the action sheet is currently
 * not displayed, the property returns nil
 */
@property (nonatomic, readonly, weak) id owner;

@end
