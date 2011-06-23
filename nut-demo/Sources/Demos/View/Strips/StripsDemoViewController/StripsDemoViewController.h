//
//  StripsDemoViewController.h
//  nut-dev
//
//  Created by Samuel Défago on 23.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * Designated initializer: init
 */
@interface StripsDemoViewController : HLSViewController {
@private
    HLSStripContainerView *m_stripContainerView;
}

@property (nonatomic, retain) IBOutlet HLSStripContainerView *stripContainerView;

@end
