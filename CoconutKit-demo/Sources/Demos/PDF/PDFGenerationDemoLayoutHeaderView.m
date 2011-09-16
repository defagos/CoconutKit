//
//  PDFGenerationDemoLayoutHeaderView.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 16.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "PDFGenerationDemoLayoutHeaderView.h"

@implementation PDFGenerationDemoLayoutHeaderView

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.titleLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize titleLabel = m_titleLabel;

@end
