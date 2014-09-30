//
//  HLSConverters.m
//  CoconutKit
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSConverters.h"

#import "HLSLogger.h"

NSString *HLSStringFromBool(BOOL yesOrNo)
{
    return yesOrNo ? @"YES" : @"NO";
}

NSString *HLSStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation)
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait: {
            return @"UIInterfaceOrientationPortrait";
            break;
        }
            
        case UIInterfaceOrientationPortraitUpsideDown: {
            return @"UIInterfaceOrientationPortraitUpsideDown";
            break;
        }
            
        case UIInterfaceOrientationLandscapeLeft: {
            return @"UIInterfaceOrientationLandscapeLeft";
            break;
        }
            
        case UIInterfaceOrientationLandscapeRight: {
            return @"UIInterfaceOrientationLandscapeRight";
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown interface orientation");
            return nil;
            break;
        }            
    }
}

NSString *HLSStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation)
{
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            return @"UIDeviceOrientationPortrait";
            break;
        }
            
        case UIDeviceOrientationPortraitUpsideDown: {
            return @"UIDeviceOrientationPortraitUpsideDown";
            break;
        }
            
        case UIDeviceOrientationLandscapeLeft: {
            return @"UIDeviceOrientationLandscapeLeft";
            break;
        }
            
        case UIDeviceOrientationLandscapeRight: {
            return @"UIDeviceOrientationLandscapeRight";
            break;
        }
            
        default: {
            HLSLoggerError(@"Unknown device orientation");
            return nil;
            break;
        }            
    }
}

NSString *HLSStringFromCATransform3D(CATransform3D transform)
{
    return [NSString stringWithFormat:@"[\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "    [%.6f, %.6f, %.6f, %.6f]\n"
            "]",
            transform.m11, transform.m12, transform.m13, transform.m14,
            transform.m21, transform.m22, transform.m23, transform.m24,
            transform.m31, transform.m32, transform.m33, transform.m34,
            transform.m41, transform.m42, transform.m43, transform.m44];
}

NSNumber *HLSUnsignedIntNumberFromString(NSString *string)
{
    if (! string) {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}
