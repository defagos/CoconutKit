//
//  WebViewDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 10.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface WebViewDemoViewController : HLSViewController {
@private
    UIWebView *_webView;
    UISwitch *_scrollEnabledSwitch;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UISwitch *scrollEnabledSwitch;

- (IBAction)toggleScrollEnabled:(id)sender;

@end
