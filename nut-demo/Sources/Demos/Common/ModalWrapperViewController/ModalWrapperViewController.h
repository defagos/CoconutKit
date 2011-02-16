//
//  ModalWrapperViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/16/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface ModalWrapperViewController : HLSPlaceholderViewController {
@private
    UINavigationBar *m_navigationBar;
    UIToolbar *m_toolbar;
}

@property (nonatomic, retain) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
