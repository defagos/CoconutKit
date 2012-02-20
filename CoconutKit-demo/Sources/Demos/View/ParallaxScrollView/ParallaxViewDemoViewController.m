//
//  ParallaxViewDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ParallaxViewDemoViewController.h"

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
    
    self.textView = nil;
    self.textScrollView = nil;
    self.scrollView1 = nil;
    self.scrollView2 = nil;
    self.scrollView3 = nil;
    self.scrollView4 = nil;
}

#pragma mark Accessors and mutators

@synthesize textView = m_textView;

@synthesize textScrollView = m_textScrollView;

@synthesize scrollView1 = m_scrollView1;

@synthesize scrollView2 = m_scrollView2;

@synthesize scrollView3 = m_scrollView3;

@synthesize scrollView4 = m_scrollView4;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textView setupParallaxWithScrollViews:[NSArray arrayWithObject:self.textScrollView]];
    
    UIImageView *imageView1 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_trees_layer.png"]] autorelease];
    [self.scrollView1 addSubview:imageView1];
    self.scrollView1.contentSize = imageView1.frame.size;
    
    UIImageView *imageView2 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_grass_layer.png"]] autorelease];
    [self.scrollView2 addSubview:imageView2];
    self.scrollView2.contentSize = imageView2.frame.size;
    
    UIImageView *imageView3 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_mountains_layer.png"]] autorelease];
    [self.scrollView3 addSubview:imageView3];
    self.scrollView3.contentSize = imageView3.frame.size;
    
    UIImageView *imageView4 = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"parallax_demo_sky_layer.png"]] autorelease];
    [self.scrollView4 addSubview:imageView4];
    self.scrollView4.contentSize = imageView4.frame.size;
    
    [self.scrollView1 setupParallaxWithScrollViews:[NSArray arrayWithObjects:self.scrollView2, self.scrollView3, self.scrollView4, nil]];
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
