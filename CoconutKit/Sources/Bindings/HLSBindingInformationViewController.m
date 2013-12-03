//
//  HLSBindingInformationViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 03/12/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

#import "HLSBindingInformationViewController.h"

#import "HLSRuntime.h"

@interface HLSBindingInformationViewController ()

@property (nonatomic, strong) HLSViewBindingInformation *bindingInformation;

@end

@implementation HLSBindingInformationViewController

#pragma mark Object creation and destruction

- (id)initWithBindingInformation:(HLSViewBindingInformation *)bindingInformation
{
    if (self = [super init]) {
        self.bindingInformation = bindingInformation;
    }
    return self;
}

- (id)init
{
    HLSForbiddenInheritedMethod();
    return nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(320.f, 480.f);
}

#pragma mark UITableViewDataSource protocol implementation

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
