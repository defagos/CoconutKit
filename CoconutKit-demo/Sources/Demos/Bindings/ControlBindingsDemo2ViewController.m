//
//  ControlBindingsDemo2ViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 22/04/14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "ControlBindingsDemo2ViewController.h"

@interface ControlBindingsDemo2ViewController ()

@property (nonatomic, strong) NSNumber *page;

@end

@implementation ControlBindingsDemo2ViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    if (self = [super init]) {
        self.page = @3;
    }
    return self;
}

@end
