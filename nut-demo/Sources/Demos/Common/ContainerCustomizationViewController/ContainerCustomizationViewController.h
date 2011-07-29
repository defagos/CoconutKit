//
//  ContainerCustomizationViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 22.07.11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller making changes to container view controllers (currently navigation elements)
 */
@interface ContainerCustomizationViewController : HLSViewController {
@private
    UIButton *m_changeButton;
    UIColor *m_originalNavigationBarTintColor;
    UIBarButtonItem *m_originalRightBarButtonItem;
}

@property (nonatomic, retain) IBOutlet UIButton *changeButton;

@end
