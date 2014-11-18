//
//  HLSLabel.m
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "HLSLabel.h"

#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@implementation HLSLabel

#pragma mark Accessors and mutators

- (void)setVerticalAlignment:(HLSLabelVerticalAlignment)verticalAlignment
{
    if (_verticalAlignment == verticalAlignment) {
        return;
    }
    
    _verticalAlignment = verticalAlignment;
    
    [self setNeedsDisplay];
}

#pragma mark UILabel drawing override points

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	
    switch (self.verticalAlignment) {
        case HLSLabelVerticalAlignmentTop: {
            textRect.origin.y = 0.f;
            break;
        }
            
        case HLSLabelVerticalAlignmentBottom: {
            textRect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect);
            break;
        }
            
        case HLSLabelVerticalAlignmentMiddle: {
        default:
            textRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect)) / 2.f;
            break;
        }
    }
    
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect
{
    CGRect rect = [self.text boundingRectWithSize:requestedRect.size
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:@{ NSFontAttributeName : self.font }
                                          context:nil];
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [self.text drawInRect:actualRect withAttributes:@{ NSFontAttributeName : self.font }];
}

@end
