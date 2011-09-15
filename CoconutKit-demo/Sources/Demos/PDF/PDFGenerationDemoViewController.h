//
//  PDFGenerationDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSViewController.h"

@interface PDFGenerationDemoViewController : HLSViewController {
@private
    UIButton *m_generateButton;
}

@property (nonatomic, retain) IBOutlet UIButton *generateButton;

@end
