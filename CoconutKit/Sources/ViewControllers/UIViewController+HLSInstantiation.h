//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HLSInstantiation)

- (instancetype)instanceInBundle:(NSBundle *)bundle;
- (instancetype)instanceWithStoryboardName:(NSString *)storyboardName inBundle:(NSBundle *)bundle;

@end
