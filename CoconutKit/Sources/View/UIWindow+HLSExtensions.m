//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "UIWindow+HLSExtensions.h"

@implementation UIWindow (HLSExtensions)

#pragma mark Accessors and mutators

- (UIViewController *)activeViewController
{
    return self.rootViewController.presentedViewController ?: self.rootViewController;
}

@end
