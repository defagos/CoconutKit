//
//  UILabel+HLSPDFLayout.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 15.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UILabel+HLSPDFLayout.h"

#import "HLSCategoryLinker.h"
#import "UIView+HLSPDFLayout.h"

HLSLinkCategory(UILabel_HLSPDFLayout)

@implementation UILabel (HLSPDFLayout)

- (void)drawElement
{    
    // Draw common view properties first
    [super drawElement];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Draw label properties
    // TODO: Even with "Adjusting font size" enabled, the font size is the one
    //       defined in the xib, and no truncation occurs (unlike what happens
    //       with a real label). Should reimplement this behaviour here
    
    UIColor *textColor = self.textColor ? self.textColor : [UIColor blackColor];
    CGContextSetFillColorWithColor(context, textColor.CGColor);
    
    UIColor *shadowColor = self.shadowColor ? self.shadowColor : [UIColor clearColor];
    CGContextSetShadowWithColor(context, self.shadowOffset, 0.f, shadowColor.CGColor);
        
    CGFloat minimumFontSize = 0.f;
    if (self.adjustsFontSizeToFitWidth) {
        minimumFontSize = [self minimumFontSize];
    }
    else {
        minimumFontSize = self.font.pointSize;
    }
    
    [self.text drawAtPoint:self.frame.origin
                  forWidth:CGRectGetWidth(self.frame)
                  withFont:self.font
               minFontSize:minimumFontSize
            actualFontSize:NULL
             lineBreakMode:self.lineBreakMode
        baselineAdjustment:self.baselineAdjustment];
    
    CGContextRestoreGState(context);
}

@end
