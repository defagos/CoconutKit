//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * For a view and a pair of begin / end notifications, traps touches outside the view frame and resigns responder
 * status if enabled
 */
@interface HLSViewTouchDetector : NSObject <UIGestureRecognizerDelegate>

/**
 * Create a touch detector for the specified text field (not retained) and notification pair
 */
- (instancetype)initWithView:(UIView *)view beginNotificationName:(NSString *)beginNotificationName endNotificationName:(NSString *)endNotificationName NS_DESIGNATED_INITIALIZER;

/**
 * If set to YES, and between the time the begin and end notifications are received, taps outside the view frame
 * make the view resign its responder status
 *
 * The default value is NO
 */
@property (nonatomic, assign, getter=isResigningFirstResponderOnTap) BOOL resigningFirstResponderOnTap;

@end
