//
//  ParallaxScrollingDemoViewController.m
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "ParallaxScrollingDemoViewController.h"

@interface ParallaxScrollingDemoViewController ()

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIScrollView *skyScrapperScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *skyScrapperImageView;

@property (nonatomic, retain) IBOutlet UIScrollView *skyScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *mountainsScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *grassScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *treesScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *skyImageView;
@property (nonatomic, retain) IBOutlet UIImageView *mountainsImageView;
@property (nonatomic, retain) IBOutlet UIImageView *grassImageView;
@property (nonatomic, retain) IBOutlet UIImageView *treesImageView;

@property (nonatomic, retain) IBOutlet UISwitch *bouncesSwitch;

- (IBAction)reset:(id)sender;
- (IBAction)toggleBounces:(id)sender;

- (void)setupParallax;

@end

@implementation ParallaxScrollingDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.textView = nil;
    self.skyScrapperScrollView = nil;
    self.skyScrapperImageView = nil;
    self.skyScrollView = nil;
    self.mountainsScrollView = nil;
    self.grassScrollView = nil;
    self.treesScrollView = nil;
    self.skyImageView = nil;
    self.mountainsImageView = nil;
    self.grassImageView = nil;
    self.treesImageView = nil;
    self.bouncesSwitch = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set content size so that scrolling can occur correctly (needed for all involved scroll views)
    self.skyScrapperScrollView.contentSize = self.skyScrapperImageView.frame.size;
    
    self.skyScrollView.contentSize = self.skyImageView.frame.size;
    self.mountainsScrollView.contentSize = self.mountainsImageView.frame.size;
    self.grassScrollView.contentSize = self.grassImageView.frame.size;
    self.treesScrollView.contentSize = self.treesImageView.frame.size;
    
    [self setupParallax];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Parallax scrolling", @"Parallax scrolling");
}

#pragma mark Action callbacks

- (IBAction)reset:(id)sender
{
    [self.treesScrollView setContentOffset:CGPointMake(0.f, 0.f) animated:YES];
}

- (IBAction)toggleBounces:(id)sender
{
    [self setupParallax];
}
     
#pragma mark Parallax effect

- (void)setupParallax
{
    [self.textView synchronizeWithScrollViews:[NSArray arrayWithObject:self.skyScrapperScrollView]
                                      bounces:self.bouncesSwitch.on];
    
    // The bounces argument is irrelevant here. The master scroll view bounces property has namely been set to NO in the nib
    [self.treesScrollView synchronizeWithScrollViews:[NSArray arrayWithObjects:self.skyScrollView, 
                                                      self.mountainsScrollView, 
                                                      self.grassScrollView, 
                                                      nil]
                                             bounces:self.bouncesSwitch.on];
}

@end
