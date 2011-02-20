//
//  TextFieldsDemoViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface TextFieldsDemoViewController : HLSViewController <UITextFieldDelegate> {
@private
    UILabel *m_instructionLabel;
    HLSTextField *m_textField1;
    HLSTextField *m_textField2;
    HLSTextField *m_textField3;
    HLSTextField *m_textField4;
    BOOL m_large;
}

@property (nonatomic, retain) IBOutlet UILabel *instructionLabel;
@property (nonatomic, retain) IBOutlet HLSTextField *textField1;
@property (nonatomic, retain) IBOutlet HLSTextField *textField2;
@property (nonatomic, retain) IBOutlet HLSTextField *textField3;
@property (nonatomic, retain) IBOutlet HLSTextField *textField4;

@end
