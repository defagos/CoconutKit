//
//  HLSLabelLocalizationInfo.h
//  CoconutKit
//
//  Created by Samuel Défago on 12.01.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * The way the localized string must be displayed
 */
typedef NS_ENUM(NSInteger, HLSLabelRepresentation) {
    HLSLabelRepresentationEnumBegin = 0,
    HLSLabelRepresentationNormal = HLSLabelRepresentationEnumBegin,
    HLSLabelRepresentationUppercase,
    HLSLabelRepresentationLowercase,
    HLSLabelRepresentationCapitalized,
    HLSLabelRepresentationEnumEnd,
    HLSLabelRepresentationEnumSize = HLSLabelRepresentationEnumEnd - HLSLabelRepresentationEnumBegin
};

/**
 * Internal class for containing the localization information attached to a UILabel (see UILabel+HLSDynamicLocalization.m)
 */
@interface HLSLabelLocalizationInfo : NSObject

/**
 * Create a localization object from a given text, processing any prefix contained in the text (see complete list in
 * UILabel+HLSDynamicLocalization.h). Perform lookup in the specified table, respectively bundle (the .strings and
 * .bundle extensions must be omitted). Setting tableName to nil is equivalent to setting it to Localizable (the
 * default localization table name). The main bundle is used if bundleName is set to nil. Bundles are searched
 * recursively in the main bundle
 */
- (instancetype)initWithText:(NSString *)text tableName:(NSString *)tableName bundleName:(NSString *)bundleName NS_DESIGNATED_INITIALIZER;

/**
 * Return YES iff the information object corresponds to localized content
 */
- (BOOL)isLocalized;

/**
 * Return YES iff some localization information is missing (localized key, corresponding translation, etc.)
 */
- (BOOL)isIncomplete;

/**
 * Build and return the corresponding localized text. Return nil if the object does not contain localized information
 * (i.e. if isLocalized returns NO)
 */
- (NSString *)localizedText;

@end

@interface HLSLabelLocalizationInfo (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end
