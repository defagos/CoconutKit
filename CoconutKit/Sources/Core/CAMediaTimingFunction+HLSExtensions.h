//
//  CAMediaTimingFunction+HLSExtensions.h
//  CoconutKit
//
//  Created by Samuel Défago on 8/23/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface CAMediaTimingFunction (HLSExtensions)

- (CAMediaTimingFunction *)inverse;

- (NSString *)controlPointsString;

@end
