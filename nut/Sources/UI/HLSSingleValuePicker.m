//
//  HLSSingleValuePicker.m
//  nut
//
//  Created by Samuel Défago on 10/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSSingleValuePicker.h"

#import "HLSLogger.h"
#import "HLSRuntimeChecks.h"

@interface HLSSingleValuePicker ()

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) HLSSingleValuePickerViewController *singleValuePickerViewController;

@end

@implementation HLSSingleValuePicker

#pragma mark Object creation and destruction

- (id)initWithValues:(NSArray *)values
{
    if ((self = [super init])) {
        self.singleValuePickerViewController = [[[HLSSingleValuePickerViewController alloc] init] autorelease];
        self.singleValuePickerViewController.values = values;
        self.singleValuePickerViewController.delegate = self;
        
        self.popoverController = [[[UIPopoverController alloc] initWithContentViewController:self.singleValuePickerViewController]
                                  autorelease];
        self.popoverController.popoverContentSize = self.singleValuePickerViewController.view.bounds.size;
    }
    return self;
}

- (id)init
{
    FORBIDDEN_INHERITED_METHOD();
    return nil;
}

- (void)dealloc
{
    self.popoverController = nil;
    self.singleValuePickerViewController = nil;
    self.delegate = nil;
    [super dealloc];
}

#pragma mark Accessors and mutators

@synthesize popoverController = m_popoverController;

@synthesize singleValuePickerViewController = m_singleValuePickerViewController;

@synthesize delegate = m_delegate;

- (void)setInitialValue:(NSString *)initialValue
{
    [self.singleValuePickerViewController setInitialValue:initialValue];
}

#pragma mark HLSSingleValuePickerViewControllerDelegate protocol implementation

- (void)singleValuePickerViewController:(HLSSingleValuePickerViewController *)singleValuePickerViewController hasPickedValue:(NSString *)value
{
    [self.delegate singleValuePicker:self hasPickedValue:value];
}

- (NSString *)singleValuePickerViewController:(HLSSingleValuePickerViewController *)singleValuePickerController labelForValue:(NSString *)value
{
    if ([self.delegate respondsToSelector:@selector(singleValuePicker:labelForValue:)]) {
        return [self.delegate singleValuePicker:self labelForValue:value];
    }
    else {
        return value;
    }
}

@end
