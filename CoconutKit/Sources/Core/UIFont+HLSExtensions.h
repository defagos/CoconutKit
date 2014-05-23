//
//  UIFont+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 1/17/13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

@interface UIFont (HLSExtensions)

/**
 * Load the font with a given file name (including extension) located in the specified bundle. If the bundle
 * parameter is nil, lookup is performed in the main bundle. The method returns YES iff the font could be
 * successfully loaded.
 *
 * Usually, custom fonts are registered using the UIAppFonts key of the application info.plist. In some cases,
 * though, e.g. in a library, you might not have access to the application info.plist. In such cases, use
 * the following method to load the fonts you need in code
 */
+ (BOOL)loadFontWithFileName:(NSString *)fileName inBundle:(NSBundle *)bundle;

/**
 * Load a font from data. The method returns YES iff the font could be successfully loaded.
 *
 * Fore more information, read the -loadFontWithFileName:inBundle: documentation
 */
+ (BOOL)loadFontWithData:(NSData *)data;

@end
