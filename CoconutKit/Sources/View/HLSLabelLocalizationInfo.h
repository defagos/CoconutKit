//
//  HLSLabelLocalizationInfo.h
//  CoconutKit
//
//  Created by Samuel Défago on 12.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

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
 * Designated initializer: init
 */
@interface HLSLabelLocalizationInfo : NSObject {
@private
    NSString *m_localizationKey;
    NSString *m_table;
    HLSLabelRepresentation m_representation;
    UIColor *m_originalBackgroundColor;
}

@property (nonatomic, retain) NSString *localizationKey;
@property (nonatomic, retain) NSString *table;
@property (nonatomic, assign) HLSLabelRepresentation representation;
@property (nonatomic, retain) UIColor *originalBackgroundColor;

@end
