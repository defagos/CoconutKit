//
//  SlideshowDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface SlideshowDemoViewController : HLSViewController <HLSSlideshowDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    HLSSlideshow *_slideshow;
    UIPickerView *_effectPickerView;
    UILabel *_currentImageNameLabel;
    UIButton *_previousButton;
    UIButton *_nextButton;
    UIButton *_playButton;
    UIButton *_pauseButton;
    UIButton *_resumeButton;
    UIButton *_stopButton;
    UIButton *_skipToSpecificButton;
    UISwitch *_randomSwitch;
    UIButton *_imageSetButton;
    UISlider *_imageDurationSlider;
    UILabel *_imageDurationLabel;
    UISlider *_transitionDurationSlider;
    UILabel *_transitionDurationLabel;
}

@property (nonatomic, retain) IBOutlet HLSSlideshow *slideshow;
@property (nonatomic, retain) IBOutlet UIPickerView *effectPickerView;
@property (nonatomic, retain) IBOutlet UILabel *currentImageNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *pauseButton;
@property (nonatomic, retain) IBOutlet UIButton *resumeButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *skipToSpecificButton;
@property (nonatomic, retain) IBOutlet UISwitch *randomSwitch;
@property (nonatomic, retain) IBOutlet UIButton *imageSetButton;
@property (nonatomic, retain) IBOutlet UISlider *imageDurationSlider;
@property (nonatomic, retain) IBOutlet UILabel *imageDurationLabel;
@property (nonatomic, retain) IBOutlet UISlider *transitionDurationSlider;
@property (nonatomic, retain) IBOutlet UILabel *transitionDurationLabel;

- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)resume:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)skipToSpecificImage:(id)sender;

- (IBAction)changeImages:(id)sender;
- (IBAction)toggleRandom:(id)sender;

- (IBAction)imageDurationValueChanged:(id)sender;
- (IBAction)transitionDurationValueChanged:(id)sender;

@end
