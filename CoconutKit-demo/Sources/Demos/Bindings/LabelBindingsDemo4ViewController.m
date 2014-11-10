//
//  LabelBindingsDemo4ViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 25.07.13.
//  Copyright (c) 2013 Samuel Défago. All rights reserved.
//

#import "LabelBindingsDemo4ViewController.h"

#import "DemoTransformer.h"
#import "Employee.h"
#import "LabelBindingsDemo4InsetViewController.h"

@implementation LabelBindingsDemo4ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        LabelBindingsDemo4InsetViewController *insetViewController = [[LabelBindingsDemo4InsetViewController alloc] init];
        [self setInsetViewController:insetViewController atIndex:0];
    }
    return self;
}

#pragma mark Accessors and mutators

- (NSDate *)currentDate
{
    return [NSDate date];
}

#pragma mark Transformers

- (NSDateFormatter *)mediumDateFormatter
{
    return [DemoTransformer mediumDateFormatter];
}

#pragma mark Action callbacks

- (IBAction)refresh:(id)sender
{
    [self refreshBindings];
}

@end
