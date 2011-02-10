//
//  ProgrammaticTableViewCell.m
//  nut-demo
//
//  Created by Samuel Défago on 2/10/11.
//  Copyright 2011 Hortis. All rights reserved.
//

#import "ProgrammaticTableViewCell.h"

@implementation ProgrammaticTableViewCell

#pragma mark Object creation and destruction

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

+ (CGFloat)height
{
    return 60.f;
}

@end
