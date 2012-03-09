//
//  SlideshowDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface SlideshowDemoViewController : HLSViewController {
@private
    HLSSlideshow *m_slideshow;
    UILabel *m_currentImageNameLabel;
    UIButton *m_previousButton;
    UIButton *m_nextButton;
    UIButton *m_playButton;
    UIButton *m_stopButton;
    UISwitch *m_randomSwitch;
    UIButton *m_imageSetButton;
}

@property (nonatomic, retain) IBOutlet HLSSlideshow *slideshow;
@property (nonatomic, retain) IBOutlet UILabel *currentImageNameLabel;
@property (nonatomic, retain) IBOutlet UIButton *previousButton;
@property (nonatomic, retain) IBOutlet UIButton *nextButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UISwitch *randomSwitch;
@property (nonatomic, retain) IBOutlet UIButton *imageSetButton;

- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)changeImages:(id)sender;
- (IBAction)toggleRandom:(id)sender;

@end
