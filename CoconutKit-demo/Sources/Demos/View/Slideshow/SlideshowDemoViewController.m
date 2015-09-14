//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "SlideshowDemoViewController.h"

@interface SlideshowDemoViewController ()

@property (nonatomic, weak) IBOutlet HLSSlideshow *slideshow;
@property (nonatomic, weak) IBOutlet UIPickerView *effectPickerView;
@property (nonatomic, weak) IBOutlet UILabel *currentImageNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *previousButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *pauseButton;
@property (nonatomic, weak) IBOutlet UIButton *resumeButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet UIButton *skipToSpecificButton;
@property (nonatomic, weak) IBOutlet UISwitch *randomSwitch;
@property (nonatomic, weak) IBOutlet UIButton *imageSetButton;
@property (nonatomic, weak) IBOutlet UISlider *imageDurationSlider;
@property (nonatomic, weak) IBOutlet UILabel *imageDurationLabel;
@property (nonatomic, weak) IBOutlet UISlider *transitionDurationSlider;
@property (nonatomic, weak) IBOutlet UILabel *transitionDurationLabel;

@end

@implementation SlideshowDemoViewController

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
    self.imageDurationLabel.text = [NSString stringWithFormat:@"%ld", lround(self.slideshow.imageDuration)];
    self.transitionDurationSlider.value = self.slideshow.transitionDuration;
    self.transitionDurationLabel.text = [NSString stringWithFormat:@"%ld", lround(self.slideshow.transitionDuration)];
    
    [self loadImages];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Slideshow", nil);
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
    static NSDictionary *s_rows;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_rows = @{ @(HLSSlideshowEffectNone) : @"HLSSlideshowEffectNone",
                    @(HLSSlideshowEffectCrossDissolve) : @"HLSSlideshowEffectCrossDissolve",
                    @(HLSSlideshowEffectKenBurns) : @"HLSSlideshowEffectKenBurns",
                    @(HLSSlideshowEffectHorizontalRibbon) : @"HLSSlideshowEffectHorizontalRibbon",
                    @(HLSSlideshowEffectInverseHorizontalRibbon) : @"HLSSlideshowEffectInverseHorizontalRibbon",
                    @(HLSSlideshowEffectVerticalRibbon) : @"HLSSlideshowEffectVerticalRibbon",
                    @(HLSSlideshowEffectInverseVerticalRibbon) : @"HLSSlideshowEffectInverseVerticalRibbon" };
    });
    return [s_rows objectForKey:@(row)];
}

#pragma mark Slideshow

- (void)loadImages
{
    if (self.imageSetButton.selected) {
        self.slideshow.imageNamesOrPaths = @[@"img_apple1.jpg", @"img_apple2.jpg", @"img_coconut1.jpg", @"img_apple3.jpg", @"img_apple4.jpg"];
    }
    else {
        self.slideshow.imageNamesOrPaths = @[@"img_coconut1.jpg", @"img_coconut2.jpg", @"img_coconut3.jpg", @"img_coconut4.jpg"];
    }
}

#pragma mark Event callbacks

- (IBAction)nextImage:(id)sender
{
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
    
    [self.slideshow skipToNextImage];
}

- (IBAction)previousImage:(id)sender
{
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
    
    [self.slideshow skipToPreviousImage];
}

- (IBAction)play:(id)sender
{
    self.slideshow.hidden = NO;
    self.effectPickerView.hidden = YES;
    self.previousButton.hidden = NO;
    self.nextButton.hidden = NO;
    self.playButton.hidden = YES;
    self.resumeButton.hidden = YES;
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
    self.pauseButton.hidden = YES;
    self.resumeButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.skipToSpecificButton.hidden = YES;
}

- (IBAction)skipToSpecificImage:(id)sender
{
    self.pauseButton.hidden = NO;
    self.resumeButton.hidden = YES;
    
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
    self.imageDurationLabel.text = [NSString stringWithFormat:@"%ld", lround(self.slideshow.imageDuration)];
}

- (IBAction)transitionDurationValueChanged:(id)sender
{
    self.slideshow.transitionDuration = round(self.transitionDurationSlider.value);
    self.transitionDurationLabel.text = [NSString stringWithFormat:@"%ld", lround(self.slideshow.transitionDuration)];
}

@end
