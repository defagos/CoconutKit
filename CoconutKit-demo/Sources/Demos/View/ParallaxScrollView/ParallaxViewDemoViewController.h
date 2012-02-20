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
    UITextView *m_textView;
    UIScrollView *m_textScrollView;
    
    UIScrollView *m_scrollView1;
    UIScrollView *m_scrollView2;
    UIScrollView *m_scrollView3;
    UIScrollView *m_scrollView4;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIScrollView *textScrollView;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView1;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView2;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView3;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView4;

@end
