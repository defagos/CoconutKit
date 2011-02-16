//
//  HLSTableViewCell.m
//  nut
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTableViewCell.h"

#import "HLSTableViewCell+Protected.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToHeightMap = nil;

@implementation HLSTableViewCell

#pragma mark Class methods for creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSTableViewCell class]) {
        return;
    }
    
    s_classNameToHeightMap = [[NSMutableDictionary dictionary] retain];
}

+ (UITableViewCell *)tableViewCellForTableView:(UITableView *)tableView
{
    // Try to find if a cell is available for the cell class identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifier]];
    
    // If not, create one lazily
    if (! cell) {
        // If a xib file name has been specified, use it, otherwise try to locate the default one (xib bearing
        // the class name)
        NSString *xibFileName = [self xibFileName];
        if (! xibFileName && [[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]) {
            xibFileName = [self className];
        }
        
        // A xib has been found, use it
        if (xibFileName) {
            NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:xibFileName owner:self options:nil];
            cell = (UITableViewCell *)[bundleContents objectAtIndex:0];
        }
        // Created programmatically
        else {
            cell = [[[[self class] alloc] initWithStyle:[self style] reuseIdentifier:[self identifier]] autorelease];
        }
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

#pragma mark Class methods for customization

+ (CGFloat)height
{
    // Cache the cell height; this way the user does pay the same performance penalty for height whether she
    // sets the UITableView rowHeight property or uses the row height callback
    NSNumber *cellHeight = [s_classNameToHeightMap objectForKey:[self className]];
    if (! cellHeight) {
        cellHeight = [NSNumber numberWithFloat:CGRectGetHeight([self tableViewCellForTableView:nil].frame)];
        [s_classNameToHeightMap setObject:cellHeight forKey:[self className]];
    }
    return [cellHeight floatValue];
}

+ (NSString *)xibFileName
{
    // Return nil by default (since can be created programmatically)
    return nil;
}

+ (UITableViewCellStyle)style
{
    return UITableViewCellStyleDefault;
}

+ (NSString *)identifier
{
    return [self className];
}

@end
