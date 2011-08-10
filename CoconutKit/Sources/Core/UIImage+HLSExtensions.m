//
//  UIImage+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UIImage+HLSExtensions.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(UIImage_HLSExtensions)

@implementation UIImage (HLSExtensions)

- (UIImage *)imageMaskedWithImage:(UIImage *)maskImage
{
	CGImageRef maskImageRef = CGImageMaskCreate(CGImageGetWidth(maskImage.CGImage),
                                                CGImageGetHeight(maskImage.CGImage),
                                                CGImageGetBitsPerComponent(maskImage.CGImage),
                                                CGImageGetBitsPerPixel(maskImage.CGImage),
                                                CGImageGetBytesPerRow(maskImage.CGImage),
                                                CGImageGetDataProvider(maskImage.CGImage),
                                                NULL,
                                                false);
    
	CGImageRef maskedImageRef = CGImageCreateWithMask(self.CGImage, maskImageRef);
    CGImageRelease(maskImageRef);
    
	UIImage *maskedImage = [UIImage imageWithCGImage:maskedImageRef];
    CGImageRelease(maskedImageRef);
    
    return maskedImage;
}

- (UIImage *)imageScaledToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0.f, 0.f, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
