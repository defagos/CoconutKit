//
//  PDFGenerationDemoLayoutTableViewCell.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSTableViewCell.h"

@interface PDFGenerationDemoLayoutTableViewCell : HLSTableViewCell {
@private
    UILabel *m_indexLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *indexLabel;

@end
