//
//  RootStackDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface RootStackDemoViewController : HLSViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIButton *m_pushButton;
    UIButton *m_popButton;
    UILabel *m_transitionLabel;
    UIPickerView *m_transitionPickerView;
}

@property (nonatomic, retain) IBOutlet UIButton *pushButton;
@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) IBOutlet UILabel *transitionLabel;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;

@end
