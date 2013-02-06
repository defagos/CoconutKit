//
//  UIView+HLSDynamicLocalization.h
//  CoconutKit
//
//  Created by Samuel Défago on 1/26/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * This header file is not public
 */
@interface UIView (HLSDynamicLocalization)

// The user-defined runtime attributes with which the localization table and bundle can be set. Not in a public
// header file to avoid direct use, but still can be set in IB thanks to KVC
@property (nonatomic, retain) NSString *locTable;
@property (nonatomic, retain) NSString *locBundle;

@end
