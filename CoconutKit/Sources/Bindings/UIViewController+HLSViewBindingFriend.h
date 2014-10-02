//
//  UIViewController+HLSViewBindingFriend.h
//  CoconutKit
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Interface meant to be used by friend classes of UIViewController (HLSViewBinding) (= classes which must have access
 * to private implementation details)
 */
@interface UIViewController (HLSViewBindingFriend)

/**
 * The bound object, if any
 */
@property (nonatomic, readonly, strong) id boundObject;

@end
