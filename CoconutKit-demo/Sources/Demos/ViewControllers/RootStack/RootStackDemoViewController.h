//
//  RootStackDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 21.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface RootStackDemoViewController : HLSViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    UIBarButtonItem *m_backBarButtonItem;
    UIBarButtonItem *m_actionSheetBarButtonItem;
    UIButton *m_popButton;
    UIPickerView *m_transitionPickerView;
    UISwitch *m_animatedSwitch;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionSheetBarButtonItem;
@property (nonatomic, retain) IBOutlet UIButton *popButton;
@property (nonatomic, retain) IBOutlet UIPickerView *transitionPickerView;
@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

- (IBAction)push:(id)sender;
- (IBAction)pop:(id)sender;
- (IBAction)pushTabBarController:(id)sender;
- (IBAction)pushNavigationController:(id)sender;
- (IBAction)hideWithModal:(id)sender;
- (IBAction)showActionSheet:(id)sender;

@end
