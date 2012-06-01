//
//  DynamicLocalizationDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 09.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "DynamicLocalizationDemoViewController.h"

@implementation DynamicLocalizationDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.coloredLabel = nil;
    self.imageView = nil;
    self.missingLocalizationVisibilitySwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize coloredLabel = m_coloredLabel;

@synthesize imageView = m_imageView;

@synthesize missingLocalizationVisibilitySwitch = m_missingLocalizationVisibilitySwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.missingLocalizationVisibilitySwitch.on = [UILabel missingLocalizationsVisible];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Dynamic localization", @"Dynamic localization");
    
    // Cannot use [UIImage imageNamed:] for localized images because of caching
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"img_localized" ofType:@"png"];
    self.imageView.image = [UIImage imageWithContentsOfFile:imagePath];
}

#pragma mark Event callbacks

- (IBAction)changeColor:(id)sender
{
    self.coloredLabel.backgroundColor = [UIColor randomColor];
}

- (IBAction)toggleMissingLocalizationVisibility:(id)sender
{
    [UILabel setMissingLocalizationsVisible:! [UILabel missingLocalizationsVisible]];
    
    UIButton *button = sender;
    button.selected = ! button.selected;
}

@end
