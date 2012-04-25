//
//  UIBarButtonItem+HLSActionSheet.h
//  CoconutKit
//
//  Created by Samuel Défago on 23.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private category used by HLSActionSheet to trap taps on bar button items so that any previously
 * opened HLSActionSheet can be properly dismissed
 *
 * Remark: This trick cannot catch the events associated with a navigation bar back button item. This
 *         case is treated in UINavigationController+HLSActionSheet
 */
@interface UIBarButtonItem (HLSActionSheet)

- (void)dismissCurrentActionSheetAndForward:(id)sender;

@end
