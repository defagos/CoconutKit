//
//  ParallaxViewDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@interface ParallaxViewDemoViewController : HLSViewController {
@private
    HLSParallaxScrollView *m_parallaxScrollView;
}

@property (nonatomic, retain) IBOutlet HLSParallaxScrollView *parallaxScrollView;

@end
