//
//  HLSSingleValuePickerViewController.m
//  nut
//
//  Created by Samuel Défago on 10/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSSingleValuePickerViewController.h"

#import "HLSAssert.h"
#import "HLSLogger.h"

@implementation HLSSingleValuePickerViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:@"nut_HLSSingleValuePickerViewController" bundle:nil])) {
        
    }
    return self;
}

- (void)dealloc
{
    self.values = nil;
    self.delegate = nil;
    [super dealloc];
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.pickerView = nil;
}

#pragma mark View lifecycle management

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pickerView.delegate = self;
}

#pragma mark Accessors and mutators

@synthesize values = m_values;

- (void)setValues:(NSArray *)values
{
    HLSAssertObjectsInEnumerationAreKindOfClass(values, NSString);
    
    // Check for self-assignment
    if (m_values == values) {
        return;
    }
    
    // Update the value
    [m_values release];
    m_values = [values retain];
    
    // Update the picker
    [self.pickerView reloadAllComponents];
}

@synthesize delegate = m_delegate;

@synthesize pickerView = m_pickerView;

- (void)setInitialValue:(NSString *)initialValue
{
    NSUInteger position = NSNotFound;
    if (initialValue) {
        // Locate the position in the value array
        position = [self.values indexOfObject:initialValue];
        if (position == NSNotFound) {
            HLSLoggerDebug(@"An initial value was set for the picker, but this value cannot be found in the picker value list");
            return;
        }
    }
    // Locate if an empty value is possible, and select it
    else {
        // Locate the position in the value array
        position = [self.values indexOfObject:@""];
        if (position == NSNotFound) {
            HLSLoggerDebug(@"No initial value set for the picker, and not empty value found in the picker value list");
            return;
        }
    }
    
    // Only one component
    [self.pickerView selectRow:position inComponent:0 animated:NO];
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.values count];
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // Only one component
    NSString *value = [self.values objectAtIndex:row];
    
    // Value translated as label if available from the delegate
    if ([self.delegate respondsToSelector:@selector(singleValuePickerViewController:labelForValue:)]) {
        return [self.delegate singleValuePickerViewController:self labelForValue:value];
    }
    // Otherwise simply display the value
    else {
        return value;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // Only one component
    [self.delegate singleValuePickerViewController:self hasPickedValue:[self.values objectAtIndex:row]];
}

@end
