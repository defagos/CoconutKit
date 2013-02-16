//
//  ParallaxScrollingDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 20.02.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface ParallaxScrollingDemoViewController : HLSViewController {
@private
    UITextView *_textView;
    UIScrollView *_skyScrapperScrollView;
    UIImageView *_skyScrapperImageView;
    
    UIScrollView *_skyScrollView;
    UIScrollView *_mountainsScrollView;
    UIScrollView *_grassScrollView;
    UIScrollView *_treesScrollView;
    UIImageView *_skyImageView;
    UIImageView *_mountainsImageView;
    UIImageView *_grassImageView;
    UIImageView *_treesImageView;
    
    UISwitch *_bouncesSwitch;
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
