//
//  ViewEffectsDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/16/13.
//  Copyright (c) 2014 Samuel Défago. All rights reserved.
//

#import "ViewEffectsDemoViewController.h"

@interface ViewEffectsDemoViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imageView1;
@property (nonatomic, weak) IBOutlet UIImageView *imageView2;

@end

@implementation ViewEffectsDemoViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.imageView1 fadeLeft:0.2f right:0.6f];
    [self.imageView2 fadeTop:0.2f bottom:0.6f];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Effects", nil);
}

@end
