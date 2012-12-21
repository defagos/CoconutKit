//
//  NSBundle+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSBundle (HLSExtensions)

/**
 * Return the friendly Hortis version number using the bundle version
 *
 * See NSString -friendlyVersionNumber extension method (NSString+HLSExtensions.h)
 */
+ (NSString *)friendlyVersionNumber;

/**
 * Return the resource bundle associated with CoconutKit
 */
+ (NSBundle *)coconutKitBundle;

@end
