//
//  HLSStandardTableViewCell.m
//  FIVB
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSStandardTableViewCell.h"

#import <objc/runtime.h>

#pragma mark Static methods

@implementation HLSStandardTableViewCell

#pragma mark Factory methods

+ (UITableViewCell *)tableViewCellForTableView:(UITableView *)tableView
{
    // Get the class name (inheritance is taken into account)
    NSString *className = [NSString stringWithUTF8String:class_getName([self class])];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:className];
    if (! cell) {
        NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
        cell = (UITableViewCell *)[bundleContents objectAtIndex:0];
    }
    
    return cell;
}

#pragma mark Object creation and destruction

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark Cell customization

- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName
{
    if (backgroundImageName) {
        self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageName]];
    }
    
    if (selectedBackgroundImageName) {
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:selectedBackgroundImageName]];
    }
}

@end
