//
//  HLSConverters.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

/**
 * Conversions to string
 */
NSString *HLSStringFromBool(BOOL yesOrNo);
NSString *HLSStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);
NSString *HLSStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation);

/**
 * Conversions to numbers
 */
NSNumber *HLSUnsignedIntNumberFromString(NSString *string);

/**
 * Conversions requiring several arguments. As methods since method signatures more explicit
 *
 * Not meant to be instantiated
 */
@interface HLSConverters : NSObject {
@private
    
}

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
