//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <Foundation/Foundation.h>

/**
 * A protocol for objects supporting validation
 */
@protocol HLSValidable <NSObject>
@required

/**
 * Must return YES iff validation is succesful
 */
- (BOOL)validate;

@end
