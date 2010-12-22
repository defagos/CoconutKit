//
//  NSDate+HLSExtensions.h
//  nut
//
//  Created by Samuel Défago on 11/26/10.
//  Copyright 2010 Hortis. All rights reserved.
//

@interface NSDate (HLSExtensions)

- (NSComparisonResult)compareDaysWithDate:(NSDate *)date;
- (BOOL)isSameDayAsDate:(NSDate *)date;

@end
