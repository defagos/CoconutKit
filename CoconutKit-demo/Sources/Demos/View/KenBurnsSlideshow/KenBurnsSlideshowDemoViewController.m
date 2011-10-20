//
//  KenBurnsSlideshowDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "KenBurnsSlideshowDemoViewController.h"

@interface KenBurnsSlideshowDemoViewController ()

- (void)play:(id)sender;
- (void)stop:(id)sender;

@end

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
    
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut1.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut2.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut3.jpg"]];
    [self.slideshow addImage:[UIImage imageNamed:@"img_coconut4.jpg"]];
    
    [self.playButton addTarget:self
                        action:@selector(play:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self
                        action:@selector(stop:)
              forControlEvents:UIControlEventTouchUpInside];
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
    [self.playButton setTitle:NSLocalizedString(@"Play", @"Play") forState:UIControlStateNormal];
    [self.stopButton setTitle:NSLocalizedString(@"Stop", @"Stop") forState:UIControlStateNormal];
}

#pragma mark Action callbacks

- (void)play:(id)sender
{
    [self.slideshow play];
}

- (void)stop:(id)sender
{
    [self.slideshow stop];
}

@end
