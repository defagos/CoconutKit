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
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Just add some customized label
        self.label = [[[UILabel alloc] initWithFrame:CGRectMake(20.f, 20.f, 400.f, 20.f)] autorelease];
        self.label.font = [UIFont systemFontOfSize:13.f];
        
        // Make cell taller than default size (if not altered, 44.f)
        self.frame = CGRectMake(self.contentView.frame.origin.x,
                                self.contentView.frame.origin.y,
                                self.contentView.frame.size.width,
                                60.f);
        
        [self.contentView addSubview:self.label];
    }
    return self;
}

- (void)dealloc
{
    self.label = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize label = m_label;

@end
