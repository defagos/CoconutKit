//
//  ActionSheetDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 25.08.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ActionSheetDemoViewController : HLSViewController {
@private
    UIButton *m_actionSheetButton;
    UILabel *m_choiceLabel;
}

@property (nonatomic, retain) IBOutlet UIButton *actionSheetButton;
@property (nonatomic, retain) IBOutlet UILabel *choiceLabel;

- (IBAction)makeChoice:(id)sender;

@end
