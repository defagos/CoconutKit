//
//  HLSLabel.m
//  CoconutKit
//
//  Created by Joris Heuberger on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSLabel.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "NSString+HLSExtensions.h"

@interface HLSLabel ()

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;

@end

@implementation HLSLabel

#pragma mark Accessors and mutators

@synthesize verticalAlignment = _verticalAlignment;

- (void)setVerticalAlignment:(HLSLabelVerticalAlignment)verticalAlignment
{
    if (_verticalAlignment == verticalAlignment) {
        return;
    }
    
    _verticalAlignment = verticalAlignment;
    
    [self setNeedsDisplay];
}

- (void)setMinimumFontSize:(CGFloat)minimumFontSize
{
    [super setMinimumFontSize:minimumFontSize];
    [self setNeedsDisplay];
}

#pragma mark UILabel drawing override points

/**
 * Vertical alignment
 *
 * Original author: jhoncybpr - http://www.iphonedevsdk.com/forum/iphone-sdk-development/35532-uilabel-vertical-align-top.html 
 */
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
	
    switch (self.verticalAlignment) {
        case HLSLabelVerticalAlignmentTop: {
            textRect.origin.y = CGRectGetMinY(bounds);
            break;
        }
            
        case HLSLabelVerticalAlignmentBottom: {
            textRect.origin.y = CGRectGetMaxY(bounds) - textRect.size.height;
            break;
        }
            
        case HLSLabelVerticalAlignmentMiddle: {
        default:
            textRect.origin.y =  CGRectGetMinY(bounds) + (bounds.size.height - textRect.size.height) / 2.f;
        }
    }
    
    return textRect;
}

- (void)drawTextInRect:(CGRect)requestedRect
{
    CGFloat fontSize = 0.f;
    if (self.adjustsFontSizeToFitWidth) {
        fontSize = [self.text fontSizeWithFont:self.font 
                             constrainedToSize:self.bounds.size 
                                   minFontSize:self.minimumFontSize
                                 numberOfLines:self.numberOfLines];
    }
    else {
        fontSize = floatmax(self.font.pointSize, self.minimumFontSize);
    }
    self.font = [UIFont fontWithName:self.font.fontName size:fontSize];
    
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

@end
