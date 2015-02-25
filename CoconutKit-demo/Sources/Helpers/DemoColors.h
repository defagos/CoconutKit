//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
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
