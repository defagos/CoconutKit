//
//  FooterView.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/11/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface FooterView : HLSNibView {
@private
    UILabel *m_label;
}

@property (nonatomic, retain) IBOutlet UILabel *label;

@end
