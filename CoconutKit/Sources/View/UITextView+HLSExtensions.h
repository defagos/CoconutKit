//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITextView (HLSExtensions)

/**
 * If set to YES, the text view resigns its first responder status when the user taps outside it
 *
 * The default value is NO
 */
@property (nonatomic, assign, getter=isResigningFirstResponderOnTap) BOOL resigningFirstResponderOnTap;

@end
