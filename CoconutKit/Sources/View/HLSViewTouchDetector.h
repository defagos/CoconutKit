//
//  HLSViewTouchDetector.h
//  CoconutKit
//
//  Created by Samuel Défago on 24.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * For a view and a pair of begin / end notifications, traps touches outside the view frame and resigns responder
 * status if enabled
 */
@interface HLSViewTouchDetector : NSObject <UIGestureRecognizerDelegate>

/**
 * Create a touch detector for the specified text field (not retained) and notification pair
 */
- (id)initWithView:(UIView *)view beginNotificationName:(NSString *)beginNotificationName endNotificationName:(NSString *)endNotificationName;

/**
 * If set to YES, and between the time the begin and end notifications are received, taps outside the view frame
 * make the view resign its responder status
 */
@property (nonatomic, assign, getter=isResigningFirstResponderOnTap) BOOL resigningFirstResponderOnTap;

@end
