//
//  HLSViewBindingInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter validation and caching
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view are mandatory, otherwise the method returns nil
 */
- (id)initWithObject:(id)object keyPath:(NSString *)keyPath formatterName:(NSString *)formatterName view:(UIView *)view;

/**
 * Return the current text corresponding to the stored binding information. If keypath information is invalid,
 * this method returns 'NaB' (Not a Binding)
 */
- (NSString *)text;

@end
