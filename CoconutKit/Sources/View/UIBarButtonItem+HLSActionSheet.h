//
//  UIBarButtonItem+HLSActionSheet.h
//  CoconutKit
//
//  Created by Samuel Défago on 23.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private class used by HLSActionSheet to trap taps on bar button items so that any previously
 * opened HLSActionSheet can be properly dismissed
 */
@interface UIBarButtonItem (HLSActionSheet)

- (SEL)swizzledAction;
- (id)swizzledTarget;

- (void)dismissCurrentActionSheetAndForward:(id)sender;

@end
