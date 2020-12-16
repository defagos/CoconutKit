//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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
+ (BOOL)loadFontWithFileName:(NSString *)fileName inBundle:(nullable NSBundle *)bundle;

/**
 * Load a font from data. The method returns YES iff the font could be successfully loaded.
 *
 * Fore more information, read the -loadFontWithFileName:inBundle: documentation
 */
+ (BOOL)loadFontWithData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
