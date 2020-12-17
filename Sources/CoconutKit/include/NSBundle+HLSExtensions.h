//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

#define CoconutKitLocalizedString(key, comment) \
    [SWIFTPM_MODULE_BUNDLE localizedStringForKey:(key) value:@"" table:nil]

@interface NSBundle (HLSExtensions)

/**
 * Return a friendly application version number, based on the main bundle version
 *
 * See NSString -friendlyVersionNumber extension method (NSString+HLSExtensions.h)
 */
+ (nullable NSString *)friendlyApplicationVersionNumber;

/**
 * Return the first bundle contained either in the main bundle, the documents or the library folder (in this order) 
 * and having a given name. The extension can be omitted, in which case another attempt with the .bundle extension 
 * will be made. If no matching bundle is found, nil is returned. Note that bundles are searched recursively, and 
 * that results are cached for faster lookup. If name is nil, the main bundle is returned
 */
+ (nullable NSBundle *)bundleWithName:(nullable NSString *)name;

/**
 * Return a friendly bundle version number
 *
 * See NSString friendlyVersionNumber extension property (NSString+HLSExtensions.h)
 */
@property (nonatomic, readonly, copy, nullable) NSString *friendlyVersionNumber;

/**
 * Return a dictionary containing both the contents of the info and localized info dictionaries
 */
@property (nonatomic, readonly, nullable) NSDictionary *fullInfoDictionary;

@end

NS_ASSUME_NONNULL_END
