//
//  NSBundle+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSBundle (HLSExtensions)

/**
 * Return the friendly Hortis application version number, based on the main bundle version
 *
 * See NSString -friendlyVersionNumber extension method (NSString+HLSExtensions.h)
 */
+ (NSString *)friendlyApplicationVersionNumber;

/**
 * Return the resource bundle associated with CoconutKit
 */
+ (NSBundle *)coconutKitBundle;

/**
 * Return the first bundle contained in the main bundle having a given name (the extension can be omitted, in which
 * case another attempt with the .bundle extension will be made). If no matching bundle is found, nil is returned. 
 * Note that bundles are searched recursively, and that results are cached for faster lookup
 */
+ (NSBundle *)bundleWithName:(NSString *)name;

/**
 * Return the friendly Hortis bundle version number
 *
 * See NSString -friendlyVersionNumber extension method (NSString+HLSExtensions.h)
 */
- (NSString *)friendlyVersionNumber;

@end
