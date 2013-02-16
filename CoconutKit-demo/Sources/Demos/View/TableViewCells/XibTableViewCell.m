//
//  XibTableViewCell.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "XibTableViewCell.h"

@implementation XibTableViewCell

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.testImageView = nil;
    self.testLabel = nil;
    [super dealloc];
}

#pragma mark Cell customisation

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setBackgroundWithImageNamed:@"cell_bkgr_brown_large.png" selectedBackgroundWithImageName:@"cell_bkgr_brown_large_selected.png"];
}

@end
