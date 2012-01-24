//
//  ActionSheetDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ActionSheetDemoViewController : HLSViewController {
@private
    UIToolbar *m_toolbar;
    UILabel *m_choiceLabel;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UILabel *choiceLabel;

- (IBAction)makeChoiceFromRectAnimated:(id)sender;
- (IBAction)makeChoiceFromRectNotAnimated:(id)sender;
- (IBAction)makeChoiceInView;
- (IBAction)makeChoiceFromToolbar:(id)sender;
- (IBAction)makeChoiceFromTabBar:(id)sender;
- (IBAction)makeChoiceFromBarButtonItemAnimated:(id)sender;
- (IBAction)makeChoiceFromBarButtonItemNotAnimated:(id)sender;

- (IBAction)resetChoice:(id)sender;

@end
