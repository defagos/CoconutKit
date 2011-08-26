//
//  ActionSheetDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ActionSheetDemoViewController : HLSViewController {
@private
    UIButton *m_showFromRectButton;
    UIButton *m_showInViewButton;
    UIToolbar *m_toolbar;
    UIBarButtonItem *m_showFromToolbarBarButtonItem;
    UIBarButtonItem *m_otherShowFromToolbarBarButtonItem;
    UIBarButtonItem *m_showFromBarButtonItemBarButtonItem;
    UILabel *m_choiceLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *showFromRectButton;
@property (nonatomic, retain) IBOutlet UIButton *showInViewButton;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showFromToolbarBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *otherShowFromToolbarBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *showFromBarButtonItemBarButtonItem;
@property (nonatomic, retain) IBOutlet UILabel *choiceLabel;

- (IBAction)makeChoiceFromRect:(id)sender;
- (IBAction)makeChoiceInView:(id)sender;
- (IBAction)makeChoiceFromToolbar:(id)sender;
- (IBAction)makeChoiceFromBarButtonItem:(id)sender;

@end
