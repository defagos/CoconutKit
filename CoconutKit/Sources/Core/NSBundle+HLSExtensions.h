//
//  NSBundle+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 2/24/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface NSBundle (HLSExtensions)

/**
 * Returns the friendly Hortis version number using the bundle version
 *
 * See NSString friendlyVersionNumber extension method (NSString+HLSExtensions.h)
 */
+ (NSString *)friendlyVersionNumber;

/**
 * Returns the "resources" bundle (images + nibs + localizations)
 */
+ (NSBundle *)coconutKitBundle;

@end
