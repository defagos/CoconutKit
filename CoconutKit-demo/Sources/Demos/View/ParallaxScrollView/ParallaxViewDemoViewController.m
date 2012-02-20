//
//  ParallaxViewDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ParallaxViewDemoViewController.h"

@interface ParallaxViewDemoViewController ()

@end

@implementation ParallaxViewDemoViewController

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
    
    self.parallaxScrollView = nil;
}

#pragma mark Accessors and mutators

@synthesize parallaxScrollView = m_parallaxScrollView;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *contentView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_trees_layer.png"]] autorelease];
    [self.parallaxScrollView setContentView:contentView];
    
    UIImageView *backgroundView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_grass_layer.png"]] autorelease];
    [self.parallaxScrollView addBackgroundView:backgroundView1];
    
    UIImageView *backgroundView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_mountains_layer.png"]] autorelease];
    [self.parallaxScrollView addBackgroundView:backgroundView2];
    
    UIImageView *backgroundView3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_sky_layer.png"]] autorelease];
    [self.parallaxScrollView addBackgroundView:backgroundView3];
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
    
    self.title = NSLocalizedString(@"Parallax scroll view", @"Parallax scroll view");
}

@end
