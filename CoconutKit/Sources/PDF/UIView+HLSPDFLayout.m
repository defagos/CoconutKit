//
//  UIView+HLSPDFLayout.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 15.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIView+HLSPDFLayout.h"

#import "HLSCategoryLinker.h"
#import "UIColor+HLSExtensions.h"

HLSLinkCategory(UIView_HLSPDFLayout)

@implementation UIView (HLSPDFLayout)

- (void)drawElement
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Background color (can be nil for default)
    UIColor *backgroundColor = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextFillRect(context, self.frame);
    
    // Subviews recursively
    for (UIView *view in self.subviews) {
        if (! [view respondsToSelector:@selector(drawElement)]) {
            HLSLoggerWarn(@"The view %@ is not a layout element. Ignored");
            continue;            
        }
        
        [view drawElement];
    }
    
    CGContextRestoreGState(context);
}

@end
