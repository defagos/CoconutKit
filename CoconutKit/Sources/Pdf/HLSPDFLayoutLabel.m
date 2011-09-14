//
//  HLSPDFLayoutLabel.m
//  CoconutKit
//
//  Created by Samuel Défago on 14.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "HLSPDFLayoutLabel.h"

#import "HLSCategoryLinker.h"

HLSLinkCategory(HLSPDFLayoutLabel)

@implementation HLSPDFLayoutLabel

#pragma mark HLSPDFLayoutElement protocol implementation

- (void)draw
{
    [self.text drawInRect:self.frame withFont:self.font];
}

@end
