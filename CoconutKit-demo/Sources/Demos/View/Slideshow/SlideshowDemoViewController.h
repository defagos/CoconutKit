//
//  SlideshowDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface SlideshowDemoViewController : HLSViewController <HLSSlideshowDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    HLSSlideshow *m_slideshow;
    UIPickerView *m_effectPickerView;
    UILabel *m_currentImageNameLabel;
    UIButton *m_previousButton;
    UIButton *m_nextButton;
    UIButton *m_playButton;
    UIButton *m_stopButton;
    UIButton *m_skipToSpecificButton;
    UISwitch *m_randomSwitch;
    UIButton *m_imageSetButton;
    UISlider *m_imageDurationSlider;
    UILabel *m_imageDurationLabel;
    UISlider *m_transitionDurationSlider;
    UILabel *m_transitionDurationLabel;
}

@property (nonatomic, retain) IBOutlet HLSSlideshow *slideshow;
@property (nonatomic, retain) IBOutlet UIPickerView *effectPickerView;
@property (nonatomic, retain) IBOutlet UILabel *currentImageNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
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
- (IBAction)stop:(id)sender;

- (IBAction)skipToSpecificImage:(id)sender;

- (IBAction)changeImages:(id)sender;
- (IBAction)toggleRandom:(id)sender;

- (IBAction)imageDurationValueChanged:(id)sender;
- (IBAction)transitionDurationValueChanged:(id)sender;

@end
