//
//  HLSGeometry.m
//  CoconutKit
//
//  Created by Samuel Défago on 19.06.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSGeometry.h"

#import "HLSLogger.h"

CGRect HLSRectForSizeContainedInRect(CGSize size, CGRect targetRect, HLSContentMode contentMode)
{
    switch (contentMode) {
        case UIViewContentModeScaleToFill: {
            return targetRect;
            break;
        }
            
        case UIViewContentModeScaleAspectFit: {
            CGSize targetSize = CGSizeMake(CGRectGetWidth(targetRect), CGRectGetHeight(targetRect));
            CGSize fittingSize = HLSSizeForAspectFittingInSize(size, targetSize);
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - fittingSize.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - fittingSize.height) / 2.f,
                              fittingSize.width,
                              fittingSize.height);
            break;
        }
            
        case UIViewContentModeScaleAspectFill: {
            CGSize targetSize = CGSizeMake(CGRectGetWidth(targetRect), CGRectGetHeight(targetRect));
            CGSize fillingSize = HLSSizeForAspectFillingInSize(size, targetSize);
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - fillingSize.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - fillingSize.height) / 2.f,
                              fillingSize.width,
                              fillingSize.height);
            break;
        }
            
        case UIViewContentModeCenter: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeTop: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeBottom: {
            return CGRectMake(CGRectGetMinX(targetRect) + (CGRectGetWidth(targetRect) - size.width) / 2.f,
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMinY(targetRect) + (CGRectGetHeight(targetRect) - size.height) / 2.f,
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeTopLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeTopRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMinY(targetRect),
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeBottomLeft: {
            return CGRectMake(CGRectGetMinX(targetRect),
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        case UIViewContentModeBottomRight: {
            return CGRectMake(CGRectGetMaxX(targetRect) - size.width,
                              CGRectGetMaxY(targetRect) - size.height,
                              size.width,
                              size.height);
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown content mode. Fixed to Scale to fill");
            return CGRectZero;
            break;
        }
    }
}

CGSize HLSSizeForAspectFittingInSize(CGSize size, CGSize targetSize)
{
    CGFloat targetRatio = targetSize.width / targetSize.height;
    CGFloat ratio = size.width / size.height;
    
    CGFloat scale = isgreaterequal(ratio, targetRatio) ? targetSize.width / size.width : targetSize.height / size.height;
    return CGSizeMake(size.width * scale, size.height * scale);
}

CGSize HLSSizeForAspectFillingInSize(CGSize size, CGSize targetSize)
{
    CGFloat targetRatio = targetSize.width / targetSize.height;
    CGFloat ratio = size.width / size.height;
    
    CGFloat scale = isgreaterequal(ratio, targetRatio) ? targetSize.height / size.height : targetSize.width / size.width;
    return CGSizeMake(size.width * scale, size.height * scale);
}
