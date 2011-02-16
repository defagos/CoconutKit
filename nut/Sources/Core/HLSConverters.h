//
//  HLSConverters.h
//  nut
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Not meant to be instantiated
 */
@interface HLSConverters : NSObject {
@private
    
}

+ (NSString *)stringFromBool:(BOOL)yesOrNo;

+ (NSString *)stringFromInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

+ (NSString *)stringFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

+ (NSNumber *)unsignedIntNumberFromString:(NSString *)string;

+ (NSDate *)dateFromString:(NSString *)string usingFormatString:(NSString *)formatString;

+ (void)convertStringValueForKey:(NSString *)sourceKey 
                    ofDictionary:(NSDictionary *)sourceDictionary
           intoStringValueForKey:(NSString *)destKey 
                    ofDictionary:(NSMutableDictionary *)destDictionary;

+ (void)convertStringValueForKey:(NSString *)sourceKey 
                    ofDictionary:(NSDictionary *)sourceDictionary
      intoUnsignedIntValueForKey:(NSString *)destKey 
                    ofDictionary:(NSMutableDictionary *)destDictionary;

+ (void)convertStringValueForKey:(NSString *)sourceKey  
                    ofDictionary:(NSDictionary *)sourceDictionary
             intoDateValueForKey:(NSString *)destKey
                    ofDictionary:(NSMutableDictionary *)destDictionary
               usingFormatString:(NSString *)formatString;

@end
