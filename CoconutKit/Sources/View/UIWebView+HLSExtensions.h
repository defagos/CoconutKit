//
//  UIWebView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIWebView (HLSExtensions)

/**
 * If set to YES, the web view background is completely transparent
 */
@property (nonatomic, assign, getter=isTransparent) BOOL transparent;

@end
