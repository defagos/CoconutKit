//
//  HLSViewTouchDetector.h
//  CoconutKit
//
//  Created by Samuel Défago on 24.07.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

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
