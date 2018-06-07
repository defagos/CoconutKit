//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

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
- (instancetype)initWithAttributedText:(nullable NSAttributedString *)attributedText text:(nullable NSString *)text tableName:(nullable NSString *)tableName bundleName:(nullable NSString *)bundleName NS_DESIGNATED_INITIALIZER;

/**
 * Return YES iff the information object corresponds to localized content
 */
@property (nonatomic, readonly, getter=isLocalized) BOOL localized;

/**
 *  Return YES iff the underlying string is attributed.
 */
@property (nonatomic, readonly, getter=isAttributed) BOOL attributed;

/**
 * Return YES iff some localization information is missing (localized key, corresponding translation, etc.)
 */
@property (nonatomic, readonly, getter=isIncomplete) BOOL incomplete;

/**
 * Build and return the corresponding localized text. Return nil if the object does not contain localized information
 * (i.e. if isLocalized returns NO)
 */
@property (nonatomic, readonly, copy, nullable) NSString *localizedText;

/**
 * Build and return the corresponding localized attributed text. Return nil if the object does not contain localized information
 * (i.e. if isLocalized returns NO)
 */
@property (nonatomic, readonly, copy, nullable) NSAttributedString *localizedAttributedText;

@end

@interface HLSLabelLocalizationInfo (UnavailableMethods)

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
