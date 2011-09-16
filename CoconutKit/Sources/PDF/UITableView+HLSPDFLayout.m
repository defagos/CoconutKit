//
//  UITableView+HLSPDFLayout.m
//  CoconutKit
//
//  Created by Samuel Défago on 16.09.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "UITableView+HLSPDFLayout.h"

#import "HLSCategoryLinker.h"
#import "UIView+HLSPDFLayout.h"

HLSLinkCategory(UITableView_HLSPDFLayout)

@implementation UITableView (HLSPDFLayout)

- (void)drawElement
{
    // TODO: Support for section headers, headers and footers
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Switch to relative coordinate system for drawing subviews (whose frame is given relative to
    // its parent view)
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
            [cell drawElement];
            
            // The simplest way to draw each cell (always having zero origin) below the previous one
            // is to translate the CTM matrix
            CGContextTranslateCTM(context, 0.f, [self.delegate tableView:self heightForRowAtIndexPath:indexPath]);
        }
    }
    
    CGContextRestoreGState(context);
}

@end
