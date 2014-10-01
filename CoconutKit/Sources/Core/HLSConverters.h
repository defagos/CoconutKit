//
//  HLSConverters.h
//  CoconutKit
//
//  Created by Samuel Défago on 9/21/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

/**
 * Conversions to string
 */
NSString *HLSStringFromBool(BOOL yesOrNo);
NSString *HLSStringFromInterfaceOrientation(UIInterfaceOrientation interfaceOrientation);
NSString *HLSStringFromDeviceOrientation(UIDeviceOrientation deviceOrientation);
NSString *HLSStringFromCATransform3D(CATransform3D transform);

/**
 * Conversions to numbers
 */
NSNumber *HLSUnsignedIntNumberFromString(NSString *string);
