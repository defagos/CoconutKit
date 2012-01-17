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
 * Designated initializer: initWithText:
 */
@interface HLSLabelLocalizationInfo : NSObject {
@private
    NSString *m_localizationKey;
    NSString *m_table;
    HLSLabelRepresentation m_representation;
    UIColor *m_originalBackgroundColor;
    BOOL m_locked;
}

/**
 * Create a localization object from a given text, processing any prefix contained in the text (see complete list in
 * UILabel+HLSDynamicLocalization.h)
 */
- (id)initWithText:(NSString *)text;

/**
 * Return YES if the information object corresponds to localized content
 */
- (BOOL)isLocalized;

/**
 * Build and return the corresponding localized text
 */
- (NSString *)localizedText;

/**
 * Used to save and restore the label background color
 */
@property (nonatomic, retain) UIColor *originalBackgroundColor;

/**
 * Used to mark the object as locked
 */
@property (nonatomic, assign, getter=isLocked) BOOL locked;

@end
