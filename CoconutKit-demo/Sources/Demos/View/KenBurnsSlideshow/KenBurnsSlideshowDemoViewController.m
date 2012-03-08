//
//  KenBurnsSlideshowDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "KenBurnsSlideshowDemoViewController.h"

@interface KenBurnsSlideshowDemoViewController ()

- (void)loadImages;

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
    self.randomSwitch = nil;
}

#pragma mark Accessors and mutators

@synthesize slideshow = m_slideshow;

@synthesize randomSwitch = m_randomSwitch;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slideshow.effect = HLSSlideShowEffectKenBurns;
    
    self.randomSwitch.on = self.slideshow.random;
    
    [self loadImages];
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

- (IBAction)nextImage:(id)sender
{
    [self.slideshow skipToNextImage];
}

- (IBAction)previousImage:(id)sender
{
    [self.slideshow skipToPreviousImage];
}

- (IBAction)play:(id)sender
{
    [self.slideshow play];
}

- (IBAction)stop:(id)sender
{
    [self.slideshow stop];
}

- (IBAction)changeImages:(id)sender
{
    m_secondSet = ! m_secondSet;
    [self loadImages];
}

- (IBAction)toggleRandom:(id)sender
{
    self.slideshow.random = self.randomSwitch.on;
}

#pragma mark Slideshow

- (void)loadImages
{
    if (m_secondSet) {
        self.slideshow.imageNamesOrPaths = [NSArray arrayWithObjects:@"img_apple1.jpg", @"img_apple2.jpg", @"img_coconut1.jpg", @"img_apple3.jpg", @"img_apple4.jpg", nil];
    }
    else {
        self.slideshow.imageNamesOrPaths = [NSArray arrayWithObjects:@"img_coconut1.jpg", @"img_coconut2.jpg", @"img_coconut3.jpg", @"img_coconut4.jpg", nil];
    }
}

@end
