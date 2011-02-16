//
//  FooterView.h
//  nut-demo
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface FooterView : HLSXibView {
@private
    UILabel *m_label;
}

@property (nonatomic, retain) IBOutlet UILabel *label;

@end
