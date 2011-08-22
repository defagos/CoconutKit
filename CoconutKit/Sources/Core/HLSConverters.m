//
//  HLSConverters.m
//  CoconutKit
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSConverters.h"

#import "HLSAssert.h"
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

NSNumber *HLSUnsignedIntNumberFromString(NSString *string)
{
    if (! string) {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@implementation HLSConverters

#pragma mark Class methods

+ (NSDate *)dateFromString:(NSString *)string usingFormatString:(NSString *)formatString
{
    if (! string) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:formatString];
    return [formatter dateFromString:string];
}

+ (void)convertStringValueForKey:(NSString *)sourceKey 
                    ofDictionary:(NSDictionary *)sourceDictionary
           intoStringValueForKey:(NSString *)destKey 
                    ofDictionary:(NSMutableDictionary *)destDictionary
{
    NSString *stringValue = [sourceDictionary objectForKey:sourceKey];
    if (stringValue) {
        [destDictionary setObject:stringValue forKey:destKey];
    }
}

+ (void)convertStringValueForKey:(NSString *)sourceKey 
                    ofDictionary:(NSDictionary *)sourceDictionary
      intoUnsignedIntValueForKey:(NSString *)destKey 
                    ofDictionary:(NSMutableDictionary *)destDictionary
{
    NSString *stringValue = [sourceDictionary objectForKey:sourceKey];
    if (stringValue) {
        NSNumber *number = HLSUnsignedIntNumberFromString(stringValue);
        if (number) {
            [destDictionary setObject:number forKey:destKey];
        }
    }
}

+ (void)convertStringValueForKey:(NSString *)sourceKey  
                    ofDictionary:(NSDictionary *)sourceDictionary
             intoDateValueForKey:(NSString *)destKey
                    ofDictionary:(NSMutableDictionary *)destDictionary
               usingFormatString:(NSString *)formatString
{
    NSString *stringValue = [sourceDictionary objectForKey:sourceKey];
    if (stringValue) {
        NSDate *date = [HLSConverters dateFromString:stringValue usingFormatString:formatString];
        if (date) {
            [destDictionary setObject:date forKey:destKey];
        }
    }
}

#pragma mark Object creation and destruction

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

@end
