//
//  KenBurnsSlideshowDemoViewController.m
//  CoconutKit-dev
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
    self.playButton = nil;
    self.stopButton = nil;
}

#pragma mark Accessors and mutators

@synthesize slideshow = m_slideshow;

@synthesize playButton = m_playButton;

@synthesize stopButton = m_stopButton;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Frames!
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut1.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut2.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut3.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut4.jpg"]];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Ken Burns effect", @"Ken Burns effect");
}

#pragma mark Action callbacks

- (IBAction)play:(id)sender
{
    [self.slideshow play];
}

- (IBAction)stop:(id)sender
{
    [self.slideshow stop];
}

@end
