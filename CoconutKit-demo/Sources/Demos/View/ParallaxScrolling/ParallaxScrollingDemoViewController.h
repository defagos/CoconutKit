//
//  ParallaxScrollingDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@interface ParallaxScrollingDemoViewController : HLSViewController {
@private
    UITextView *m_textView;
    UIScrollView *m_skyScrapperScrollView;
    UIImageView *m_skyScrapperImageView;
    
    UIScrollView *m_skyScrollView;
    UIScrollView *m_mountainsScrollView;
    UIScrollView *m_grassScrollView;
    UIScrollView *m_treesScrollView;
    UIImageView *m_skyImageView;
    UIImageView *m_mountainsImageView;
    UIImageView *m_grassImageView;
    UIImageView *m_treesImageView;
    
    UISwitch *m_bouncesSwitch;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIScrollView *skyScrapperScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *skyScrapperImageView;

@property (nonatomic, retain) IBOutlet UIScrollView *skyScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *mountainsScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *grassScrollView;
@property (nonatomic, retain) IBOutlet UIScrollView *treesScrollView;
@property (nonatomic, retain) IBOutlet UIImageView *skyImageView;
@property (nonatomic, retain) IBOutlet UIImageView *mountainsImageView;
@property (nonatomic, retain) IBOutlet UIImageView *grassImageView;
@property (nonatomic, retain) IBOutlet UIImageView *treesImageView;

@property (nonatomic, retain) IBOutlet UISwitch *bouncesSwitch;

- (IBAction)reset:(id)sender;
- (IBAction)toggleBounces:(id)sender;

@end
