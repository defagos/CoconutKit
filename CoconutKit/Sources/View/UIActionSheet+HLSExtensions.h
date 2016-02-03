//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIActionSheet (HLSExtensions)

/**
 * The object which is showing the action sheet. Can be a UIBarButtonItem, a UIToolbar, a UITabBar
 * or simply a UIView depending on which show... method was called. If the action sheet is currently
 * not displayed, the property returns nil
 */
@property (nonatomic, readonly, weak) id owner;

@end
