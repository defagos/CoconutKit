//
//  SlideshowDemoViewController.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

#import "SlideshowDemoViewController.h"

@interface SlideshowDemoViewController ()

- (void)loadImages;

@end

@implementation SlideshowDemoViewController

#pragma mark Object creation and destruction

- (void)releaseViews
{
    [super releaseViews];
    
    self.slideshow = nil;
    self.effectPickerView = nil;
    self.currentImageNameLabel = nil;
    self.previousButton = nil;
    self.nextButton = nil;
    self.playButton = nil;
    self.pauseButton = nil;
    self.resumeButton = nil;
    self.stopButton = nil;
    self.skipToSpecificButton = nil;
    self.randomSwitch = nil;
    self.imageSetButton = nil;
    self.imageDurationSlider = nil;
    self.imageDurationLabel = nil;
    self.transitionDurationSlider = nil;
    self.transitionDurationLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize slideshow = m_slideshow;

@synthesize effectPickerView = m_effectPickerView;

@synthesize currentImageNameLabel = m_currentImageNameLabel;

@synthesize previousButton = m_previousButton;

@synthesize nextButton = m_nextButton;

@synthesize playButton = m_playButton;

@synthesize pauseButton = m_pauseButton;

@synthesize resumeButton = m_resumeButton;

@synthesize stopButton = m_stopButton;

@synthesize skipToSpecificButton = m_skipToSpecificButton;

@synthesize randomSwitch = m_randomSwitch;

@synthesize imageSetButton = m_imageSetButton;

@synthesize imageDurationSlider = m_imageDurationSlider;

@synthesize imageDurationLabel = m_imageDurationLabel;

@synthesize transitionDurationSlider = m_transitionDurationSlider;

@synthesize transitionDurationLabel = m_transitionDurationLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.slideshow.hidden = YES;
    self.slideshow.delegate = self;
    
    self.effectPickerView.dataSource = self;
    self.effectPickerView.delegate = self;
    
    self.currentImageNameLabel.text = nil;
    self.previousButton.hidden = YES;
    self.nextButton.hidden = YES;
    
    self.pauseButton.hidden = YES;
    self.resumeButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.skipToSpecificButton.hidden = YES;
        
    self.randomSwitch.on = self.slideshow.random;
    
    self.imageDurationSlider.value = self.slideshow.imageDuration;
    self.imageDurationLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)round(self.slideshow.imageDuration)];
    self.transitionDurationSlider.value = self.slideshow.transitionDuration;
    self.transitionDurationLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)round(self.slideshow.transitionDuration)];
    
    [self loadImages];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotate
{
    if (! [super shouldAutorotate]) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & HLSInterfaceOrientationMaskAll;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Slideshow", @"Slideshow");
}

#pragma mark HLSSlideshowDelegate protocol implementation

- (void)slideshow:(HLSSlideshow *)slideshow willShowImageWithNameOrPath:(NSString *)imageNameOrPath
{
    HLSLoggerInfo(@"Will show image %@; currentImageNameOrPath = %@", imageNameOrPath, [slideshow currentImageNameOrPath]);
    
    self.currentImageNameLabel.text = @"<->";
}

- (void)slideshow:(HLSSlideshow *)slideshow didShowImageWithNameOrPath:(NSString *)imageNameOrPath
{
    HLSLoggerInfo(@"Did show image %@; currentImageNameOrPath = %@", imageNameOrPath, [slideshow currentImageNameOrPath]);
    
    self.currentImageNameLabel.text = [imageNameOrPath lastPathComponent];
}

- (void)slideshow:(HLSSlideshow *)slideshow willHideImageWithNameOrPath:(NSString *)imageNameOrPath
{
    HLSLoggerInfo(@"Will hide image %@; currentImageNameOrPath = %@", imageNameOrPath, [slideshow currentImageNameOrPath]);
}

- (void)slideshow:(HLSSlideshow *)slideshow didHideImageWithNameOrPath:(NSString *)imageNameOrPath
{
    HLSLoggerInfo(@"Did hide image %@; currentImageNameOrPath = %@", imageNameOrPath, [slideshow currentImageNameOrPath]);
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return HLSSlideshowEffectEnumSize;
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case HLSSlideshowEffectNone: {
            return @"HLSSlideshowEffectNone";
            break;
        }
            
        case HLSSlideshowEffectCrossDissolve: {
            return @"HLSSlideshowEffectCrossDissolve";
            break;
        }
            
        case HLSSlideshowEffectKenBurns: {
            return @"HLSSlideshowEffectKenBurns";
            break;
        }
            
        case HLSSlideshowEffectHorizontalRibbon: {
            return @"HLSSlideshowEffectHorizontalRibbon";
            break;
        }
            
        case HLSSlideshowEffectInverseHorizontalRibbon: {
            return @"HLSSlideshowEffectInverseHorizontalRibbon";
            break;
        }
            
        case HLSSlideshowEffectVerticalRibbon: {
            return @"HLSSlideshowEffectVerticalRibbon";
            break;
        }
            
        case HLSSlideshowEffectInverseVerticalRibbon: {
            return @"HLSSlideshowEffectInverseVerticalRibbon";
            break;
        }
            
        default: {
            return @"";
            break;
        }            
    }
}

#pragma mark Slideshow

- (void)loadImages
{
    if (self.imageSetButton.selected) {
        self.slideshow.imageNamesOrPaths = [NSArray arrayWithObjects:@"img_apple1.jpg", @"img_apple2.jpg", @"img_coconut1.jpg", @"img_apple3.jpg", @"img_apple4.jpg", nil];
    }
    else {
        self.slideshow.imageNamesOrPaths = [NSArray arrayWithObjects:@"img_coconut1.jpg", @"img_coconut2.jpg", @"img_coconut3.jpg", @"img_coconut4.jpg", nil];
    }
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
    self.slideshow.hidden = NO;
    self.effectPickerView.hidden = YES;
    self.previousButton.hidden = NO;
    self.nextButton.hidden = NO;
    self.playButton.hidden = YES;
    self.pauseButton.hidden = NO;
    self.stopButton.hidden = NO;
    self.skipToSpecificButton.hidden = NO;
    
    self.slideshow.effect = [self.effectPickerView selectedRowInComponent:0];
    [self.slideshow play];
}

- (IBAction)pause:(id)sender
{
    self.pauseButton.hidden = YES;
    self.resumeButton.hidden = NO;
    
    [self.slideshow pause];
}

- (IBAction)resume:(id)sender
{
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
    
    [self.slideshow resume];
}

- (IBAction)stop:(id)sender
{
    [self.slideshow stop];
    
    self.slideshow.hidden = YES;
    self.effectPickerView.hidden = NO;
    self.currentImageNameLabel.text = nil;
    self.previousButton.hidden = YES;
    self.nextButton.hidden = YES;
    self.playButton.hidden = NO;
    self.stopButton.hidden = YES;
    self.skipToSpecificButton.hidden = YES;
}

- (IBAction)skipToSpecificImage:(id)sender
{
    [self.slideshow skipToImageWithNameOrPath:@"img_coconut1.jpg"];
}

- (IBAction)changeImages:(id)sender
{
    self.imageSetButton.selected = ! self.imageSetButton.selected;
    [self loadImages];
}

- (IBAction)toggleRandom:(id)sender
{
    self.slideshow.random = self.randomSwitch.on;
}

- (IBAction)imageDurationValueChanged:(id)sender
{
    self.slideshow.imageDuration = round(self.imageDurationSlider.value);
    self.imageDurationLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)round(self.slideshow.imageDuration)];
}

- (IBAction)transitionDurationValueChanged:(id)sender
{
    self.slideshow.transitionDuration = round(self.transitionDurationSlider.value);
    self.transitionDurationLabel.text = [NSString stringWithFormat:@"%d", (NSInteger)round(self.slideshow.transitionDuration)];
}

@end
