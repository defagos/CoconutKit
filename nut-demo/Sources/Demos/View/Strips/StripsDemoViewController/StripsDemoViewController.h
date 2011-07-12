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
@interface StripsDemoViewController : HLSViewController <HLSStripContainerViewDelegate, UITextFieldDelegate> {
@private
    HLSStripContainerView *m_stripContainerView;
    UILabel *m_infoLabel;
    UILabel *m_addLabel;
    UITextField *m_addBeginPositionTextField;
    UITextField *m_addLengthTextField;
    UIButton *m_addButton;
    UILabel *m_splitlabel;
    UITextField *m_splitPositionTextField;
    UIButton *m_splitButton;
    UILabel *m_deleteAtPositionLabel;
    UITextField *m_deletePositionTextField;
    UIButton *m_deleteAtPositionButton;
    UILabel *m_deleteAtIndexLabel;
    UITextField *m_deleteIndexTextField;
    UIButton *m_deleteAtIndexButton;
    UILabel *m_userInteractionLabel;
    UISwitch *m_userInteractionSwitch;
    UIButton *m_clearButton;
}

@property (nonatomic, retain) IBOutlet HLSStripContainerView *stripContainerView;
@property (nonatomic, retain) IBOutlet UILabel *infoLabel;
@property (nonatomic, retain) IBOutlet UILabel *addLabel;
@property (nonatomic, retain) IBOutlet UITextField *addBeginPositionTextField;
@property (nonatomic, retain) IBOutlet UITextField *addLengthTextField;
@property (nonatomic, retain) IBOutlet UIButton *addButton;
@property (nonatomic, retain) IBOutlet UILabel *splitlabel;
@property (nonatomic, retain) IBOutlet UITextField *splitPositionTextField;
@property (nonatomic, retain) IBOutlet UIButton *splitButton;
@property (nonatomic, retain) IBOutlet UILabel *deleteAtPositionLabel;
@property (nonatomic, retain) IBOutlet UITextField *deletePositionTextField;
@property (nonatomic, retain) IBOutlet UIButton *deleteAtPositionButton;
@property (nonatomic, retain) IBOutlet UILabel *deleteAtIndexLabel;
@property (nonatomic, retain) IBOutlet UITextField *deleteIndexTextField;
@property (nonatomic, retain) IBOutlet UIButton *deleteAtIndexButton;
@property (nonatomic, retain) IBOutlet UILabel *userInteractionLabel;
@property (nonatomic, retain) IBOutlet UISwitch *userInteractionSwitch;
@property (nonatomic, retain) IBOutlet UIButton *clearButton;

- (IBAction)addStrip:(id)sender;
- (IBAction)splitStrip:(id)sender;
- (IBAction)deleteStripAtPosition:(id)sender;
- (IBAction)deleteStripAtIndex:(id)sender;
- (IBAction)toggleUserInteraction:(id)sender;
- (IBAction)clearStrips:(id)sender;

@end
