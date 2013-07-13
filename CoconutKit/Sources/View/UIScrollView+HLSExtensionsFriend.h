//
//  UIScrollView+HLSExtensionsFriend.h
//  CoconutKit
//
//  Created by Samuel Défago on 13.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of UIScrollView (HLSExtensions) (= classes which must have access to 
 * private implementation details)
 */
@interface UIScrollView (HLSExtensionsFriend)

/**
 * Set the content offset so that a given view is visible
 */
- (void)scrollViewToVisible:(UIView *)view animated:(BOOL)animated;

@end
