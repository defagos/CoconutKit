//
//  CursorSelectedFolderView.m
//  CoconutKit-demo
//
//  Created by Samuel Défago on 17.06.11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "CursorSelectedFolderView.h"

@implementation CursorSelectedFolderView

#pragma mark Object creation and destruction

- (void)dealloc
{
    self.nameLabel = nil;
    
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize nameLabel = _nameLabel;

@end
