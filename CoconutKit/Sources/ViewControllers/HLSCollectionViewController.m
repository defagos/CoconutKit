//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  Licence information is available from the LICENCE file.
//

#import "HLSCollectionViewController.h"

#import "UIViewController+HLSInstantiation.h"

@implementation HLSCollectionViewController

#pragma mark Object creation and destruction

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
