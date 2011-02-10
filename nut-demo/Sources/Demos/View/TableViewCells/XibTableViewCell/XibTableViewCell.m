//
//  XibTableViewCell.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "XibTableViewCell.h"

@implementation XibTableViewCell

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.imageView = nil;
    self.label = nil;
    [super dealloc];
}

#pragma mark Cell customization

- (void)awakeFromNib
{
    [self setBackgroundWithImageNamed:@"cell_bkgr_brown_large.png" selectedBackgroundWithImageName:@"cell_bkgr_brown_large_selected.png"];
}

#pragma mark Accessors and mutators

@synthesize imageView = m_imageView;

@synthesize label = m_label;

#pragma mark Class methods

+ (CGFloat)height
{
    // Must match the size of the resource in the xib file
    return 50.f;
}

@end
