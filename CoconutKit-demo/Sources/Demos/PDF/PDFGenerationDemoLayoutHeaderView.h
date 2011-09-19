//
//  PDFGenerationDemoLayoutHeaderView.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface PDFGenerationDemoLayoutHeaderView : HLSNibView {
@private
    UILabel *m_titleLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@end
