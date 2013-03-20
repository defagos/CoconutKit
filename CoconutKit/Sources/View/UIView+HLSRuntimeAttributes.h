//
//  UIView+HLSRuntimeAttributes.h
//  CoconutKit
//
//  Created by Samuel Défago on 1/26/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * This header file is not public. These properties are not meant to be set directly, but rather in IB. Thanks to
 * KVC these properties do not need to be made public
 */
@interface UIView (HLSRuntimeAttributes)

// User-defined runtime attributes for dynamic localization
@property (nonatomic, retain) NSString *locTable;
@property (nonatomic, retain) NSString *locBundle;

@end
