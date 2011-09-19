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

@interface UITableView (HLSPDFLayoutPrivate)

- (UIView *)headerViewForSection:(NSInteger)section;
- (UIView *)footerViewForSection:(NSInteger)section;

- (CGFloat)cellHeightAtIndexPath:(NSIndexPath *)indexPath;
- (CGFloat)headerViewHeightForSection:(NSInteger)section;
- (CGFloat)footerViewHeightForSection:(NSInteger)section;

@end

@implementation UITableView (HLSPDFLayout)

- (void)drawElement
{
    // We do not call super here. This would draw other elements, like scroll bars. Moreover, this would
    // draw the background as it is in the nib file, but this is not what we want: We want the height to
    // be determined by the table contents
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Calculate the total height
    CGFloat totalHeight = 0.f;
    NSInteger numberOfSections = [self.dataSource numberOfSectionsInTableView:self];
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        // Header
        UIView *headerView = [self headerViewForSection:section];
        if (headerView) {
            totalHeight += [self headerViewHeightForSection:section];
        }
        
        // Cells
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            totalHeight += [self cellHeightAtIndexPath:indexPath];
        }
        
        // Footer
        UIView *footerView = [self footerViewForSection:section];
        if (footerView) {
            totalHeight += [self footerViewHeightForSection:section];
        }
    }
    
    // Draw the background. Must begin with the background since "paint" is applied in layers
    UIColor *backgroundColor = self.backgroundColor ? self.backgroundColor : [UIColor clearColor];
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    
    CGRect exactFrame = CGRectMake(CGRectGetMinX(self.frame), 
                                   CGRectGetMinY(self.frame),
                                   CGRectGetWidth(self.frame), 
                                   totalHeight);
    CGContextFillRect(context, exactFrame);
        
    // Switch to relative coordinate system for drawing subviews (whose frame is given relative to
    // its parent view)
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    
    // Draw contents
    for (NSInteger section = 0; section < numberOfSections; ++section) {
        // Header
        UIView *headerView = [self headerViewForSection:section];
        if (headerView) {
            [headerView drawElement];
            
            // Upate the CTM matrix to draw the next element at the correct location
            CGContextTranslateCTM(context, 0.f, [self headerViewHeightForSection:section]);
        }
        
        // Cells
        NSInteger numberOfRows = [self.dataSource tableView:self numberOfRowsInSection:section];
        for (NSInteger row = 0; row < numberOfRows; ++row) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell *cell = [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
            NSAssert(cell != nil, @"Missing cell at indexPath %@", indexPath);
            [cell drawElement];
            
            // Upate the CTM matrix to draw the next element at the correct location
            CGContextTranslateCTM(context, 0.f, [self cellHeightAtIndexPath:indexPath]);
        }
        
        // Footer
        UIView *footerView = [self footerViewForSection:section];
        if (footerView) {
            [footerView drawElement];
            
            // Upate the CTM matrix to draw the next element at the correct location
            CGContextTranslateCTM(context, 0.f, [self footerViewHeightForSection:section]);
        }
    }
    
    CGContextRestoreGState(context);
}

@end

@implementation UITableView (HLSPDFLayoutPrivate)

- (UIView *)headerViewForSection:(NSInteger)section
{
    UIView *headerView = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        headerView = [self.delegate tableView:self viewForHeaderInSection:section];
    }
    
    if (! headerView && [self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                                    0.f, 
                                                                    CGRectGetWidth(self.frame),
                                                                    [self headerViewHeightForSection:section])] 
                          autorelease];
        label.text = [self.dataSource tableView:self titleForHeaderInSection:section];
        headerView = label;
    }
    return headerView;
}

- (UIView *)footerViewForSection:(NSInteger)section
{
    UIView *footerView = nil;
    if ([self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        footerView = [self.delegate tableView:self viewForFooterInSection:section];
    }
    
    if (! footerView && [self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0.f,
                                                                    0.f, 
                                                                    CGRectGetWidth(self.frame),
                                                                    [self footerViewHeightForSection:section])] 
                          autorelease];
        label.text = [self.dataSource tableView:self titleForFooterInSection:section];
        footerView = label;
    }
    return footerView;    
}

- (CGFloat)cellHeightAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
        return [self.delegate tableView:self heightForRowAtIndexPath:indexPath];
    }
    else {
        return self.rowHeight;
    }
}

- (CGFloat)headerViewHeightForSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)]) {
        return [self.delegate tableView:self heightForHeaderInSection:section];
    }
    else {
        return self.sectionHeaderHeight;
    }
}

- (CGFloat)footerViewHeightForSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)]) {
        return [self.delegate tableView:self heightForFooterInSection:section];
    }
    else {
        return self.sectionFooterHeight;
    }
}

@end
