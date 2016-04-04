//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (HLSExtensions)

/**
 * If set to YES, the text view resigns its first responder status when the user taps outside it
 *
 * The default value is NO
 */
@property (nonatomic, getter=isResigningFirstResponderOnTap) BOOL resigningFirstResponderOnTap;

@end

NS_ASSUME_NONNULL_END
