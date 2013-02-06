//
//  HLSLabelLocalizationInfo.h
//  CoconutKit
//
//  Created by Samuel Défago on 12.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * The way the localized string must be displayed
 */
typedef enum {
    HLSLabelRepresentationEnumBegin = 0,
    HLSLabelRepresentationNormal = HLSLabelRepresentationEnumBegin,
    HLSLabelRepresentationUppercase,
    HLSLabelRepresentationLowercase,
    HLSLabelRepresentationCapitalized,
    HLSLabelRepresentationEnumEnd,
    HLSLabelRepresentationEnumSize = HLSLabelRepresentationEnumEnd - HLSLabelRepresentationEnumBegin
} HLSLabelRepresentation;

/**
 * Internal class for containing the localization information attached to a UILabel (see UILabel+HLSDynamicLocalization.m)
 *
 * Designated initializer: -initWithText:tableName:bundleName:
 */
@interface HLSLabelLocalizationInfo : NSObject {
@private
    NSString *m_localizationKey;
    NSString *m_tableName;
    NSString *m_bundleName;
    HLSLabelRepresentation m_representation;
    BOOL m_locked;
}

/**
 * Create a localization object from a given text, processing any prefix contained in the text (see complete list in
 * UILabel+HLSDynamicLocalization.h). Perform lookup in the specified table, respectively bundle (the .strings and
 * .bundle extensions must be omitted). Setting tableName to nil is equivalent to setting it to Localizable (the
 * default localization table name). The main bundle is used if bundleName is set to nil. Bundles are searched
 * recursively in the main bundle
 */
- (id)initWithText:(NSString *)text tableName:(NSString *)tableName bundleName:(NSString *)bundleName;

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

/**
 * Used to mark the object as locked
 */
@property (nonatomic, assign, getter=isLocked) BOOL locked;

@end
