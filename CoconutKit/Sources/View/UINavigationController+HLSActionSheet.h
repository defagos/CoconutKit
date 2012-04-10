//
//  UINavigationController+HLSActionSheet.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 25.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * A private category used by HLSActionSheet to trap when the user navigates back within a navigation controller. If
 * an action sheet is presented from a navigation bar button item, clicking the back button item namely does not
 * dismiss it (even with the UIBarButton+HLSActionSheet injection). This category fixes this special case
 */
@interface UINavigationController (HLSActionSheet)

@end
