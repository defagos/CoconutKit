//
//  HLSViewBindingInformation.h
//  CoconutKit
//
//  Created by Samuel Défago on 18.06.13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#define HLSViewBindingInformationEmptyObject [NSNull null]

/**
 * Private class encapsulating view binding information, and performing lazy binding parameter validation and caching
 */
@interface HLSViewBindingInformation : NSObject

/**
 * Store view binding information. A keypath and a view are mandatory, otherwise the method returns nil. The object
 * parameter can be one of the following:
 *   - HLSViewBindingInformationEmptyObject in which case the value returned by the keypath is nil (binding to an empty 
 *     object)
 *   - a non-nil object, which the keypath is applied to (binding to an object)
 *   - nil, in which case the keypath is applied to the responder chain starting with view
 */
- (id)initWithObject:(id)object keyPath:(NSString *)keyPath formatterName:(NSString *)formatterName view:(UIView *)view;

/**
 * Return the current text corresponding to the stored binding information. If keypath information is invalid,
 * this method returns 'NaB' (Not a Binding)
 */
- (NSString *)text;

@end
