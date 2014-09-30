//
//  HLSLabel.h
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

/**
 * Vertical alignments
 */
typedef NS_ENUM(NSInteger, HLSLabelVerticalAlignment) {
    HLSLabelVerticalAlignmentEnumBegin = 0,
    HLSLabelVerticalAlignmentMiddle = HLSLabelVerticalAlignmentEnumBegin,
    HLSLabelVerticalAlignmentTop,
    HLSLabelVerticalAlignmentBottom,
    HLSLabelVerticalAlignmentEnumEnd,
    HLSLabelVerticalAlignmentEnumSize = HLSLabelVerticalAlignmentEnumEnd - HLSLabelVerticalAlignmentEnumBegin
};

/**
 * An HLSLabel is a UILabel providing vertical text alignment. No text truncation or font size adjustment is currently
 * made
 */
@interface HLSLabel : UILabel

/**
 * Vertical alignment of the string in the label
 *
 * Default value is HLSLabelVerticalAlignmentMiddle
 */
@property (nonatomic, assign) HLSLabelVerticalAlignment verticalAlignment;

@end
