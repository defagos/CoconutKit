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
    UISwitch *m_randomSwitch;
    BOOL m_secondSet;
}

@property (nonatomic, retain) IBOutlet HLSSlideshow *slideshow;
@property (nonatomic, retain) IBOutlet UISwitch *randomSwitch;

- (IBAction)nextImage:(id)sender;
- (IBAction)previousImage:(id)sender;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)changeImages:(id)sender;
- (IBAction)toggleRandom:(id)sender;

@end
