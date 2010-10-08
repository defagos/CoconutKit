//
//  HLSViewPlaceholder.h
//  nut
//
//  Created by Samuel Défago on 9/28/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * ---------------------------
 * This protocol is deprecated
 * ---------------------------
 *
 * Protocol implemented by objects (most probably view controllers) exhibiting a placeholder view for view composition
 *
 * Remark: If your placeholder view is set using Interface Builder, just redeclare this method in your class, adding the 
 *         IBOutlet keyword to it.
 */
@protocol HLSViewPlaceholder <NSObject>
@required
@property (nonatomic, retain) UIView *placeholderView;

@end
