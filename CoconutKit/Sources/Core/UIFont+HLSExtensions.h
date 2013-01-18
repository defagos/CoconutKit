//
//  UIFont+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 1/17/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface UIFont (HLSExtensions)

+ (BOOL)loadFontWithFileName:(NSString *)fileName inBundle:(NSBundle *)bundle;
+ (BOOL)loadFontWithData:(NSData *)data;

@end
