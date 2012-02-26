//
//  KenBurnsSlideshowDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface KenBurnsSlideshowDemoViewController : HLSViewController {
@private
    HLSKenBurnsSlideshow *m_slideshow;
    UISwitch *m_randomSwitch;
    BOOL m_secondSet;
}

@property (nonatomic, retain) IBOutlet HLSKenBurnsSlideshow *slideshow;
@property (nonatomic, retain) IBOutlet UISwitch *randomSwitch;

- (IBAction)play:(id)sender;
- (IBAction)stop:(id)sender;

- (IBAction)changeImages:(id)sender;
- (IBAction)toggleRandom:(id)sender;

@end
