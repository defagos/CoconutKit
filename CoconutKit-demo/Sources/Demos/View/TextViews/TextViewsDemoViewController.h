//
//  TextViewsDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 1/16/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface TextViewsDemoViewController : HLSViewController {
@private
    HLSTextView *m_textView1;
    HLSTextView *m_textView2;
    HLSTextView *m_textView3;
}

@property (nonatomic, retain) IBOutlet HLSTextView *textView1;
@property (nonatomic, retain) IBOutlet HLSTextView *textView2;
@property (nonatomic, retain) IBOutlet HLSTextView *textView3;

@end
