//
//  DemoColors.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 20.03.13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

// Custom colors defined in a UIColor subclass
@interface DemoColor : UIColor

+ (UIColor *)customDemo1Color;
+ (UIColor *)customDemo2Color;

@end

// Custom colors defined in a UIColor category
@interface UIColor (DemoColors)

+ (UIColor *)customCategory1Color;
+ (UIColor *)customCategory2Color;

@end
