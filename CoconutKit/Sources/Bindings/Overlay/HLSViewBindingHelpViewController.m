//
//  HLSViewBindingHelpViewController.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.11.14.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "HLSViewBindingHelpViewController.h"

#import "NSBundle+HLSExtensions.h"

@interface HLSViewBindingHelpViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@end

@implementation HLSViewBindingHelpViewController

#pragma mark Object creation and destruction

- (instancetype)init
{
    return [self initWithBundle:[NSBundle coconutKitBundle]];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Help", nil);
}

@end
