//
//  KenBurnsSlideshowDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "KenBurnsSlideshowDemoViewController.h"

@implementation KenBurnsSlideshowDemoViewController

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
    
    self.slideshow = nil;
}

#pragma mark Accessors and mutators

@synthesize slideshow = m_slideshow;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slideshow.images = [NSArray arrayWithObjects:[UIImage imageNamed:@"img_coconut1.jpg"],
                             [UIImage imageNamed:@"img_coconut2.jpg"],
                             [UIImage imageNamed:@"img_coconut3.jpg"],
                             [UIImage imageNamed:@"img_coconut4.jpg"],
                             nil];
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
    
    self.title = NSLocalizedString(@"Ken Burns effect", @"Ken Burns effect");
}

#pragma mark Event callbacks

- (IBAction)play:(id)sender
{
    [self.slideshow play];
}

- (IBAction)stop:(id)sender
{
    [self.slideshow stop];
}

@end
