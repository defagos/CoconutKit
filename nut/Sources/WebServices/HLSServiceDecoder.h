//
//  HLSServiceDecoder.h
//  nut
//
//  Created by Samuel Défago on 7/31/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSServiceAnswer.h"
#import "HLSServiceObject.h"

/**
 * "Pure virtual" methods
 */
@protocol HLSServiceDecoderAbstract

@optional
/**
 * Must return and array of HLSServiceObjectDescriptions extracted from HLSServiceAnswer. If an error is encountered, an NSError
 * object must be returned. If no service object description has been found as a result of decoding, the function is free
 * to return either nil or an empty array.
 */
- (NSArray *)decodeAnswer:(HLSServiceAnswer *)answer didFailWithError:(NSError **)pError;

@end

/**
 * You do not instantiate a decoder yourself. This step is performed by the service broker
 * which uses it. The broker calls the init method, that is why you must not define another
 * initializer in subclasses (it would never be called).
 *
 * Designated initializer: init
 */
@interface HLSServiceDecoder : NSObject <HLSServiceDecoderAbstract> {
@private
    
}

@end
