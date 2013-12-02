//
//  UIView+HLSViewBindingFriend.h
//  CoconutKit
//
//  Created by Samuel Défago on 02.12.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSViewBindingInformation.h"

@interface UIView (HLSViewBindingFriend)

@property (nonatomic, readonly, strong) HLSViewBindingInformation *bindingInformation;

@end
