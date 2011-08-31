//
//  UIView+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface UIView (HLSExtensions)

/**
 * Use this property if you want to tag your view with a string instead of an integer
 */
@property (nonatomic, retain) NSString *tag_hls;

/**
 * Use this dictionary to convey additional information about your views
 */
@property (nonatomic, retain) NSDictionary *userInfo_hls;

@end
