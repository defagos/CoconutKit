//
//  UIImageView+HLSPDFLayout.m
//  CoconutKit
//
//  Created by Samuel Défago on 15.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIImageView+HLSPDFLayout.h"

#import "HLSFloat.h"
#import "HLSLogger.h"
#import "UIView+HLSPDFLayout.h"

@implementation UIImageView (HLSPDFLayout)

- (void)drawElement
{    
    // Draw common view properties first
    [super drawElement];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    // Depending on the content mode which is used, draws the image as on views. This does not make sense in UIView+HLSPDFLayout:
    // This property is usuayll used when the bounds of a view change, but when creating PDFs there is no resizing involved. But
    // this setting still is important for image views (determine where the image is located and how it is stretched in the image
    // view)
    CGRect frame = CGRectZero;
    switch (self.contentMode) {            
        case UIViewContentModeScaleAspectFit: 
        case UIViewContentModeScaleAspectFill: {
            // Aspect ratios of frame and image
            CGFloat frameRatio = CGRectGetWidth(self.frame) / CGRectGetHeight(self.frame);
            CGFloat imageRatio = self.image.size.width / self.image.size.height;
            
            // Calculate the zoom scale so that the image fits exactly inside the frame
            CGFloat zoomScale;
            if ((self.contentMode == UIViewContentModeScaleAspectFit && floatge(imageRatio, frameRatio))
                    || (self.contentMode == UIViewContentModeScaleAspectFill && ! floatge(imageRatio, frameRatio))) {
                zoomScale = CGRectGetWidth(self.frame) / self.image.size.width;
            }
            else {
                zoomScale = CGRectGetHeight(self.frame) / self.image.size.height;
            }
            
            CGFloat resizedImageWidth = self.image.size.width * zoomScale;
            CGFloat resizedImageHeight = self.image.size.height * zoomScale;
            frame = CGRectMake(CGRectGetMinX(self.frame) + (CGRectGetWidth(self.frame) - resizedImageWidth) / 2.f,
                               CGRectGetMinY(self.frame) + (CGRectGetHeight(self.frame) - resizedImageHeight) / 2.f,
                               resizedImageWidth,
                               resizedImageHeight);
            break;
        }
            
        case UIViewContentModeCenter: {
            frame = CGRectMake(CGRectGetMinX(self.frame) + (CGRectGetWidth(self.frame) - self.image.size.width) / 2.f,
                               CGRectGetMinY(self.frame) + (CGRectGetHeight(self.frame) - self.image.size.height) / 2.f,
                               self.image.size.width,
                               self.image.size.height);            
            break;
        }
            
        case UIViewContentModeTop: {
            frame = CGRectMake(CGRectGetMinX(self.frame) + (CGRectGetWidth(self.frame) - self.image.size.width) / 2.f,
                               CGRectGetMinY(self.frame),
                               self.image.size.width,
                               self.image.size.height);
            break;
        }
            
        case UIViewContentModeBottom: {
            frame = CGRectMake(CGRectGetMinX(self.frame) + (CGRectGetWidth(self.frame) - self.image.size.width) / 2.f,
                               CGRectGetMaxY(self.frame) - self.image.size.height,
                               self.image.size.width,
                               self.image.size.height);            
            break;
        }
            
        case UIViewContentModeLeft: {
            frame = CGRectMake(CGRectGetMinX(self.frame),
                               CGRectGetMinY(self.frame) + (CGRectGetHeight(self.frame) - self.image.size.height) / 2.f,
                               self.image.size.width,
                               self.image.size.height);
            break;
        }
            
        case UIViewContentModeRight: {
            frame = CGRectMake(CGRectGetMaxX(self.frame) - self.image.size.width,
                               CGRectGetMinY(self.frame) + (CGRectGetHeight(self.frame) - self.image.size.height) / 2.f,
                               self.image.size.width,
                               self.image.size.height);
            break;
        }
            
        case UIViewContentModeTopLeft: {
            frame = CGRectMake(CGRectGetMinX(self.frame),
                               CGRectGetMinY(self.frame),
                               self.image.size.width,
                               self.image.size.height);
            break;
        }
            
        case UIViewContentModeTopRight: {
            frame = CGRectMake(CGRectGetMaxX(self.frame) - self.image.size.width,
                               CGRectGetMinY(self.frame),
                               self.image.size.width,
                               self.image.size.height);
            break;
        }
            
        case UIViewContentModeBottomLeft: {
            frame = CGRectMake(CGRectGetMinX(self.frame),
                               CGRectGetMaxY(self.frame) - self.image.size.height,
                               self.image.size.width,
                               self.image.size.height);            
            break;
        }
            
        case UIViewContentModeBottomRight: {
            frame = CGRectMake(CGRectGetMaxX(self.frame) - self.image.size.width,
                               CGRectGetMaxY(self.frame) - self.image.size.height,
                               self.image.size.width,
                               self.image.size.height);            
            break;
        }
            
        case UIViewContentModeScaleToFill: {
            frame = self.frame;
            break;
        }
        case UIViewContentModeRedraw: {
            HLSLoggerWarn(@"Redraw content mode does not make sense for image views in PDF layouts. Nothing drawn");
            frame = CGRectZero;
            break;
        }
        default: {
            HLSLoggerError(@"Unknown content mode. Fixed to Scale to fill");
            frame = self.frame;
            break;
        }
    }
    
    CGContextClipToRect(context, self.frame);
    [self.image drawInRect:frame];
    
    CGContextRestoreGState(context);
}

@end
