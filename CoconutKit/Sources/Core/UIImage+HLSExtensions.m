//
//  UIImage+HLSExtensions.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.07.11.
//  Copyright 2011 Samuel Défago. All rights reserved.
//

#import "UIImage+HLSExtensions.h"

#import "NSBundle+HLSExtensions.h"

@implementation UIImage (HLSExtensions)

+ (instancetype)coconutKitImageNamed:(NSString *)imageName
{
    static NSString *s_relativeBundlePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *coconutKitBundlePath = [[NSBundle coconutKitBundle] bundlePath];
        if ([coconutKitBundlePath hasPrefix:mainBundlePath]) {
            s_relativeBundlePath = [coconutKitBundlePath stringByReplacingCharactersInRange:NSMakeRange(0, [mainBundlePath length] + 1) withString:@""];
        }
    });
    
    // The CoconutKit bundle is located within the main bundle. Can use -[UIImage imageNamed:] and its caching
    // mechanism
    if (s_relativeBundlePath) {
        NSString *imagePath = [s_relativeBundlePath stringByAppendingPathComponent:imageName];
        return [UIImage imageNamed:imagePath];
    }
    // The CoconutKit bundle is located outside the main bundle. -[UIImage imageNamed:] cannot be used
    else {
        NSString *imagePath = [[[NSBundle coconutKitBundle] bundlePath] stringByAppendingPathComponent:imageName];
        return [UIImage imageWithContentsOfFile:imagePath];
    }
}

+ (instancetype)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

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
