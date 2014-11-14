//
//  UIView+HLSViewBindingFriend.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.12.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingInformation.h"

/**
 * Interface meant to be used by friend classes of UIView (HLSViewBinding) (= classes which must have access to private 
 * implementation details)
 */
@interface UIView (HLSViewBindingFriend)

/**
 * The attached binding information, if any
 */
@property (nonatomic, readonly, strong) HLSViewBindingInformation *bindingInformation;

- (void)updateView;

@end
