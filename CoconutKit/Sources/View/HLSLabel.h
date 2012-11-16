//
//  HLSLabel.h
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Vertical alignments
 */
typedef enum {
    HLSLabelVerticalAlignmentEnumBegin = 0,
    HLSLabelVerticalAlignmentMiddle = HLSLabelVerticalAlignmentEnumBegin,
    HLSLabelVerticalAlignmentTop,
    HLSLabelVerticalAlignmentBottom,
    HLSLabelVerticalAlignmentEnumEnd,
    HLSLabelVerticalAlignmentEnumSize = HLSLabelVerticalAlignmentEnumEnd - HLSLabelVerticalAlignmentEnumBegin
} HLSLabelVerticalAlignment;

/**
 * An HLSLabel is like a UILabel but differs in the following ways:
 *   - a vertical alignment can be specified
 *   - the font size can be automatically adjusted to fit the label width (adjustsFontSizeToFitWidth property)
 *     even if several lines can be displayed by the label (numberOfLines property)
 *   - the minimumFontSize property can be used to set a minimal font size when adjustments occur (even if the 
 *     number of lines is larger than 1). Unlike UILabel, the font size can never be smaller than this minimum
 *     value (even if no size adjustment is needed)
 *   - the baselineAdjustment property is ignored
 */
@interface HLSLabel : UILabel {
@private
    HLSLabelVerticalAlignment _verticalAlignment;
}

/**
 * Vertical alignment of the string in the label
 *
 * Default value is HLSLabelVerticalAlignmentMiddle
 */
@property (nonatomic, assign) HLSLabelVerticalAlignment verticalAlignment;

@end
