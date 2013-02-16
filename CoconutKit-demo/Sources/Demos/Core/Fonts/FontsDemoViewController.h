//
//  FontsDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 1/18/13.
//  Copyright (c) 2013 Hortis. All rights reserved.
//

@interface FontsDemoViewController : HLSViewController {
@private
    UILabel *_label;
    UIWebView *_webView;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
