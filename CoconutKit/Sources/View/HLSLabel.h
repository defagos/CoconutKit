//
//  HLSLabel.h
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

/**
 * Vertical alignement of the string in the label (top, middle or bottom)
 */
typedef enum {
    HLSLabelVerticalAlignmentEnumBegin = 0,
    HLSLabelVerticalAlignmentTop = HLSLabelVerticalAlignmentEnumBegin,
    HLSLabelVerticalAlignmentMiddle,
    HLSLabelVerticalAlignmentBottom,
    HLSLabelVerticalAlignmentEnumEnd,
    HLSLabelVerticalAlignmentEnumSize = HLSLabelVerticalAlignmentEnumEnd - HLSLabelVerticalAlignmentEnumBegin
} HLSLabelVerticalAlignment;


/**
 * A label that can have several lines, adjust its font size to fit its width and have a vertical alignment.
 *
 * Note: unlike UILabel, you can have several lines AND the font size changing to fit the text in the label 
 *       (if numberOfLines>1 and adjustsFontSizeToFitWidth is set to YES)
 */

@interface HLSLabel : UILabel {
@private
	HLSLabelVerticalAlignment _verticalAlignment;
}

@property (nonatomic, assign) HLSLabelVerticalAlignment verticalAlignment;

@end
