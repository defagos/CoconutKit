//
//  HLSViewBindingHelpViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingHelpViewController.h"

#import "NSBundle+HLSExtensions.h"

@implementation HLSViewBindingHelpViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    return [self initWithBundle:[NSBundle coconutKitBundle]];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Help", nil);
}

@end
