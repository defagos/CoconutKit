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

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.imageView = nil;
    self.missingLocalizationVisibilitySwitch = nil;
}

#pragma mark Accessors and mutators

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
    
    // TODO: Display localized image in imageView
}

#pragma mark Action callbacks

- (IBAction)toggleMissingLocalizationVisibility:(id)sender
{
    [UILabel setMissingLocalizationsVisible:! [UILabel missingLocalizationsVisible]];
    
    UIButton *button = sender;
    button.selected = ! button.selected;
}

@end
