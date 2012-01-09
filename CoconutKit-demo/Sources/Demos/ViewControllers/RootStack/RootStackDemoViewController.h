//
//  RootStackDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface RootStackDemoViewController : HLSViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *m_popButton;
    UIPickerView *m_transitionPickerView;
}

@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;

- (IBAction)pushButtonClicked:(id)sender;
- (IBAction)popButtonClicked:(id)sender;

@end
