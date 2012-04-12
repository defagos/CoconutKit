//
//  CoconutTableViewCell.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 12.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "CoconutTableViewCell.h"

@implementation CoconutTableViewCell

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.thumbnailImageView = nil;
    self.nameLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize thumbnailImageView = m_thumbnailImageView;

@synthesize nameLabel = m_nameLabel;

@end
