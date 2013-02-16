//
//  TextFieldsDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/12/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface TextFieldsDemoViewController : HLSViewController <UITextFieldDelegate> {
@private
    HLSTextField *_textField1;
    HLSTextField *_textField2;
    HLSTextField *_textField3;
    HLSTextField *_textField4;
}

@property (nonatomic, retain) IBOutlet HLSTextField *textField1;
@property (nonatomic, retain) IBOutlet HLSTextField *textField2;
@property (nonatomic, retain) IBOutlet HLSTextField *textField3;
@property (nonatomic, retain) IBOutlet HLSTextField *textField4;

@end
