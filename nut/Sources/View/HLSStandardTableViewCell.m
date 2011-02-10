//
//  HLSStandardTableViewCell.m
//  nut
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSStandardTableViewCell.h"

#import "HLSStandardWidgetConstants.h"
#import <objc/runtime.h>

#pragma mark Static methods

@implementation HLSStandardTableViewCell

#pragma mark Factory methods

+ (UITableViewCell *)tableViewCellFromXibFileWithName:(NSString *)xibFileName forTableView:(UITableView *)tableView
{
    // Try to find if a cell is available for the cell class identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifier]];
    
    // If not, create one lazily from xib
    if (! cell) {
        NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:xibFileName owner:self options:nil];
        cell = (UITableViewCell *)[bundleContents objectAtIndex:0];
    }
    
    return cell;
}

+ (UITableViewCell *)tableViewCellWithStyle:(UITableViewCellStyle)style forTableView:(UITableView *)tableView
{
    // Try to find if a cell is available for the cell class identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifier]];
    
    // If not, create one lazily
    if (! cell) {
        cell = [[[self class] alloc] initWithStyle:style reuseIdentifier:[self identifier]];
    }
    
    return cell;    
}

#pragma mark Cell customization

- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName
{
    if (backgroundImageName) {
        self.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageName]] autorelease];
    }
    
    if (selectedBackgroundImageName) {
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:selectedBackgroundImageName]] autorelease];
    }
}

#pragma mark Class methods

+ (NSString *)identifier
{
    // Use the class name by default
    return [NSString stringWithUTF8String:class_getName([self class])];
}

+ (CGFloat)height
{
    return kTableViewCellStandardHeight;
}

@end
