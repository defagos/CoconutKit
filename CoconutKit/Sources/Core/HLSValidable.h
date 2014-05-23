//
//  HLSValidable.h
//  CoconutKit
//
//  Created by Samuel Défago on 10/11/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

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
