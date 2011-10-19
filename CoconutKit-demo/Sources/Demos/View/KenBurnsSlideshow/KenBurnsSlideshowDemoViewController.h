//
//  KenBurnsSlideshowDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 17.10.11.
//  Copyright (c) 2011 Hortis. All rights reserved.
//

@interface KenBurnsSlideshowDemoViewController : HLSViewController {
@private
    HLSKenBurnsSlideshow *m_slideshow;
}

@property (nonatomic, retain) IBOutlet HLSKenBurnsSlideshow *slideshow;

@end
