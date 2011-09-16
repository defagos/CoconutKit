//
//  PDFGenerationDemoLayoutTableViewCell.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PDFGenerationDemoLayoutTableViewCell.h"

@implementation PDFGenerationDemoLayoutTableViewCell

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.indexLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize indexLabel = m_indexLabel;

@end
