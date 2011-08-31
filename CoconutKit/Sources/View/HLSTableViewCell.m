//
//  HLSTableViewCell.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSTableViewCell.h"

#import "HLSLogger.h"
#import "HLSTableViewCell+Protected.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToHeightMap = nil;

@interface HLSTableViewCell ()

+ (NSString *)findNibName;

@end

@implementation HLSTableViewCell

#pragma mark Class methods for initialization and creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSTableViewCell class]) {
        return;
    }
    
    // The height map is common for the whole HLSTableViewCell inheritance hierarchy
    s_classNameToHeightMap = [[NSMutableDictionary dictionary] retain];
}

+ (id)cellForTableView:(UITableView *)tableView
{
    // Try to find if a cell is available for the cell class identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifier]];
    
    // If not, create one lazily
    if (! cell) {
        NSString *nibName = [self findNibName];
        
        // A xib file is used
        if (nibName) {
            NSArray *bundleContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
            if ([bundleContents count] == 0) {
                HLSLoggerError(@"Missing cell object in xib file %@", nibName);
                return nil;
            }
            cell = (UITableViewCell *)[bundleContents objectAtIndex:0];
            
            // Check that the reuse identifier defined in the xib is correct
            if (! [[cell reuseIdentifier] isEqual:[self identifier]]) {
                HLSLoggerWarn(@"The reuse identifier in the xib %@ (%@) does not match the one defined for the class "
                              "(%@). The reuse mechanism will not work properly and the table view will suffer from "
                              "performance issues", nibName, [cell reuseIdentifier], [self identifier]);
            }
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
        UIImage *backgroundImage = [UIImage imageNamed:backgroundImageName];
        if (backgroundImage) {
            self.backgroundView = [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
        }
        else {
            HLSLoggerWarn(@"The image %@ does not exist", backgroundImageName);
            self.backgroundView = nil;
        }
        
    }
    
    if (selectedBackgroundImageName) {
        UIImage *selectedBackgroundImage = [UIImage imageNamed:selectedBackgroundImageName];
        if (selectedBackgroundImage) {
            self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
        }
        else {
            HLSLoggerWarn(@"The image %@ does not exist", selectedBackgroundImage);
            self.selectedBackgroundView = nil;
        }
        self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:selectedBackgroundImage] autorelease];
    }
}

#pragma mark Class methods related to customization

+ (CGFloat)height
{
    // Cache the cell height; this way the user does pay the same performance penalty for height whether she
    // sets the UITableView rowHeight property or uses the row height callback
    NSNumber *cellHeight = [s_classNameToHeightMap objectForKey:[self className]];
    if (! cellHeight) {
        // Instantiate a dummy cell
        UITableViewCell *cell = [self cellForTableView:nil];
        cellHeight = [NSNumber numberWithFloat:CGRectGetHeight(cell.frame)];
        [s_classNameToHeightMap setObject:cellHeight forKey:[self className]];
    }
    return [cellHeight floatValue];
}

+ (NSString *)nibName
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

// Return the xib file to be used if any, nil otherwise
+ (NSString *)findNibName
{
    // If a xib file name has been specified, use it, otherwise try to locate the default one (xib bearing
    // the class name)
    NSString *nibName = [self nibName];
    if (! nibName && [[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]) {
        nibName = [self className];
    }
    return nibName;
}

@end
