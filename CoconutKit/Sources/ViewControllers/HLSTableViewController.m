//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSTableViewController.h"

#import "UIViewController+HLSInstantiation.h"

@implementation HLSTableViewController

- (instancetype)initWithStoryboardName:(NSString *)storyboardName bundle:(NSBundle *)bundle
{
    return [self instanceWithStoryboardName:storyboardName inBundle:bundle];
}

- (instancetype)initWithBundle:(NSBundle *)bundle
{
    return [self instanceInBundle:bundle];
}

- (instancetype)init
{
    return [self initWithBundle:nil];
}

@end
