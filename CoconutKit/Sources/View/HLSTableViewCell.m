//
//  HLSTableViewCell.m
//  CoconutKit
//
//  Created by Samuel Défago on 8/21/10.
//  Copyright 2010 Samuel Défago. All rights reserved.
//

#import "HLSTableViewCell.h"

#import "HLSLogger.h"
#import "HLSTableViewCell+Protected.h"
#import "NSArray+HLSExtensions.h"
#import "NSObject+HLSExtensions.h"

static NSMutableDictionary *s_classNameToSizeMap = nil;

@implementation HLSTableViewCell

#pragma mark Class methods for initialization and creation

+ (void)initialize
{
    // Perform initialization once for the whole inheritance hierarchy
    if (self != [HLSTableViewCell class]) {
        return;
    }
    
    // The size map is common for the whole HLSTableViewCell inheritance hierarchy
    s_classNameToSizeMap = [NSMutableDictionary dictionary];
}

+ (instancetype)cellForTableView:(UITableView *)tableView
{
    // Try to find if a cell is available for the cell class identifier
    HLSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self identifier]];
    
    // If not, create one lazily
    if (! cell) {
        NSString *nibName = [self findNibName];
        
        // A xib file is used
        if (nibName) {
            NSBundle *bundle = [self bundle] ?: [NSBundle mainBundle];
            
            NSArray *bundleContents = [bundle loadNibNamed:nibName owner:nil options:nil];
            if ([bundleContents count] == 0) {
                HLSLoggerError(@"Missing cell object in xib file %@", nibName);
                return nil;
            }
            
            // Get the first object and check that it is what we expect
            id firstObject = [bundleContents firstObject];
            if (! [firstObject isKindOfClass:self]) {
                HLSLoggerError(@"The cell object must be the first one in the xib file, and must be of type %@", [self className]);
                return nil;
            }
            
            cell = (HLSTableViewCell *)firstObject;
            
            // Check that the reuse identifier defined in the xib is correct
            if (! [[cell reuseIdentifier] isEqualToString:[self identifier]]) {
                HLSLoggerWarn(@"The reuse identifier in the xib %@ (%@) does not match the one defined for the class "
                              "(%@). The reuse mechanism will not work properly and the table view will suffer from "
                              "performance issues", nibName, [cell reuseIdentifier], [self identifier]);
            }
        }
        // Created programmatically
        else {
            cell = [[[self class] alloc] initWithStyle:[self style] reuseIdentifier:[self identifier]];
        }
    }
    
    return cell;
}

#pragma mark Cell customisation

- (void)setBackgroundWithImageNamed:(NSString *)backgroundImageName
    selectedBackgroundWithImageName:(NSString *)selectedBackgroundImageName
{
    if (backgroundImageName) {
        UIImage *backgroundImage = [UIImage imageNamed:backgroundImageName];
        if (backgroundImage) {
            self.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        }
        else {
            HLSLoggerWarn(@"The image %@ does not exist", backgroundImageName);
            self.backgroundView = nil;
        }
    }
    
    if (selectedBackgroundImageName) {
        UIImage *selectedBackgroundImage = [UIImage imageNamed:selectedBackgroundImageName];
        if (selectedBackgroundImage) {
            self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
        }
        else {
            HLSLoggerWarn(@"The image %@ does not exist", selectedBackgroundImage);
            self.selectedBackgroundView = nil;
        }
        self.selectedBackgroundView = [[UIImageView alloc] initWithImage:selectedBackgroundImage];
    }
}

#pragma mark Class methods related to customisation

+ (CGFloat)height
{
    return [self size].height;
}

+ (CGFloat)width
{
    return [self size].width;
}

+ (CGSize)size
{
    // Cache the cell size; this way the user does pay the same performance penalty for height whether she
    // sets the UITableView rowHeight property or uses the row height callback
    NSValue *cellSizeValue = [s_classNameToSizeMap objectForKey:[self className]];
    if (! cellSizeValue) {
        // Instantiate a dummy cell
        UITableViewCell *cell = [self cellForTableView:nil];
        cellSizeValue = [NSValue valueWithCGSize:cell.bounds.size];
        [s_classNameToSizeMap setObject:cellSizeValue forKey:[self className]];
    }
    return [cellSizeValue CGSizeValue];
}

+ (NSString *)nibName
{
    // Return nil by default (since can be created programmatically)
    return nil;
}

+ (NSBundle *)bundle
{
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
    NSBundle *bundle = [self bundle] ?: [NSBundle mainBundle];
    if (! nibName && [bundle pathForResource:[self className] ofType:@"nib"]) {
        nibName = [self className];
    }
    return nibName;
}

@end
