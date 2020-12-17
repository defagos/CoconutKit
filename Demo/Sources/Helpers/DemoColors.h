//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

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

NS_ASSUME_NONNULL_END
