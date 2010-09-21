//
//  HLSConverters.m
//  nut
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSConverters.h"

#import "HLSRuntimeChecks.h"

@implementation HLSConverters

#pragma mark Class methods

+ (NSNumber *)unsignedIntNumberFromString:(NSString *)string
{
    if (! string) {
        return nil;
    }
    
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

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
        NSNumber *number = [HLSConverters unsignedIntNumberFromString:stringValue];
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
¿
#pragma mark Object creation and destruction

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
