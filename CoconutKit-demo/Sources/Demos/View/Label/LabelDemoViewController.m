//
//  LabelDemoViewController.m
//  CoconutKit-demo
//
//  Created by Joris Heuberger on 13.04.12.
//  Copyright (c) 2012 Samuel Défago. All rights reserved.
//

#import "LabelDemoViewController.h"

static NSArray *s_textExamples = nil;
static NSArray *s_fontNames = nil;

@interface LabelDemoViewController ()

@property (nonatomic, weak) IBOutlet HLSLabel *label;
@property (nonatomic, weak) IBOutlet UILabel *standardLabel;
@property (nonatomic, weak) IBOutlet UIPickerView *textPickerView;
@property (nonatomic, weak) IBOutlet UIPickerView *fontPickerView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *baselineAdjustmentSegmentedControl;
@property (nonatomic, weak) IBOutlet UISlider *numberOfLinesSlider;
@property (nonatomic, weak) IBOutlet UILabel *numberOfLinesLabel;
@property (nonatomic, weak) IBOutlet UISlider *fontSizeSlider;
@property (nonatomic, weak) IBOutlet UILabel *fontSizeLabel;
@property (nonatomic, weak) IBOutlet UISwitch *adjustsFontSizeToFitWidthSwitch;
@property (nonatomic, weak) IBOutlet UISlider *minFontSizeSlider;
@property (nonatomic, weak) IBOutlet UILabel *minFontSizeLabel;
@property (nonatomic, weak) IBOutlet UISegmentedControl *verticalAlignmentSegmentedControl;
@property (nonatomic, weak) IBOutlet UIPickerView *lineBreakModePickerView;

@end

@implementation LabelDemoViewController

#pragma mark Class methods

+ (void)initialize
{
    if (self != [LabelDemoViewController class]) {
        return;
    }
    
    s_textExamples = [NSArray arrayWithObjects:@"Lorem ipsum",
                      @"Lorem ipsum dolor sit amet, consetetur sadipscing elitr",
                      @"At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
                      @"ABCDEFGHIJKLMNOPQRSTUVWXYZ abcdefghijklmnopqrstuvwxyz",
                      @"--------- -- --------- -------",
                      @"",
                      @"......... ... ......... .... .", nil];
    
    NSMutableArray *fontNames = [NSMutableArray array];
    NSArray *familyNames = [[UIFont familyNames] sortedArrayUsingSelector:@selector(localizedCompare:)];
    for (NSString *familyName in familyNames) {
        NSArray *familyFontNames = [[UIFont fontNamesForFamilyName:familyName] sortedArrayUsingSelector:@selector(localizedCompare:)];
        [fontNames addObjectsFromArray:familyFontNames];
    }
    s_fontNames = [NSArray arrayWithArray:fontNames];
}

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.textPickerView.dataSource = self;
    self.textPickerView.delegate = self;
    
    self.fontPickerView.dataSource = self;
    self.fontPickerView.delegate = self;
    
    self.lineBreakModePickerView.dataSource = self;
    self.lineBreakModePickerView.delegate = self;
    
    [self reloadData];
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Label", nil);
    
    [self.baselineAdjustmentSegmentedControl setTitle:NSLocalizedString(@"Baselines", nil) forSegmentAtIndex:0];
    [self.baselineAdjustmentSegmentedControl setTitle:NSLocalizedString(@"Centers", nil) forSegmentAtIndex:1];
    [self.baselineAdjustmentSegmentedControl setTitle:NSLocalizedString(@"None", nil) forSegmentAtIndex:2];
    
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Middle", nil) forSegmentAtIndex:0];
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Top", nil) forSegmentAtIndex:1];
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Bottom", nil) forSegmentAtIndex:2];
    
    [self reloadData];
}

#pragma mark UIPickerViewDataSource protocol implementation

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.textPickerView) {
        return [s_textExamples count];
    }
    else if (pickerView == self.fontPickerView) {
        return [s_fontNames count];
    }
    else if (pickerView == self.lineBreakModePickerView) {
        return UILineBreakModeMiddleTruncation + 1;
    }
    else {
        HLSLoggerError(@"Unknown picker view");
        return 0;
    }
}

#pragma mark UIPickerViewDelegate protocol implementation

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.textPickerView) {
        return [s_textExamples objectAtIndex:row];
    }
    else if (pickerView == self.fontPickerView) {
        return [s_fontNames objectAtIndex:row];
    }
    else if (pickerView == self.lineBreakModePickerView) {
        switch (row) {                
            case UILineBreakModeCharacterWrap: {
                return @"UILineBreakModeCharacterWrap";
                break;
            }
                
            case UILineBreakModeClip: {
                return @"UILineBreakModeClip";
                break;
            }
                
            case UILineBreakModeHeadTruncation: {
                return @"UILineBreakModeHeadTruncation";
                break;
            }
                
            case UILineBreakModeTailTruncation: {
                return @"UILineBreakModeTailTruncation";
                break;
            }
                
            case UILineBreakModeMiddleTruncation: {
                return @"UILineBreakModeMiddleTruncation";
                break;
            }
                
            case UILineBreakModeWordWrap:
            default: {
                return @"UILineBreakModeWordWrap";
                break;
            }
        }
    }
    else {
        HLSLoggerError(@"Unknown picker view");
        return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self reloadData];
}

#pragma mark Updating the view

- (void)reloadData
{
    NSString *text = [s_textExamples objectAtIndex:[self.textPickerView selectedRowInComponent:0]];
    NSString *fontName = [s_fontNames objectAtIndex:[self.fontPickerView selectedRowInComponent:0]];
    UILineBreakMode lineBreakMode = [self.lineBreakModePickerView selectedRowInComponent:0];
    UIBaselineAdjustment baselineAdjustment = [self.baselineAdjustmentSegmentedControl selectedSegmentIndex];
    
    self.label.font = [UIFont fontWithName:fontName size:self.fontSizeSlider.value];
    self.label.minimumFontSize = self.minFontSizeSlider.value;
    self.label.numberOfLines = (NSInteger)self.numberOfLinesSlider.value;
    self.label.verticalAlignment = self.verticalAlignmentSegmentedControl.selectedSegmentIndex;
    self.label.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidthSwitch.on;
    self.label.baselineAdjustment = baselineAdjustment;
    self.label.lineBreakMode = lineBreakMode;
    self.label.text = text;
    
    self.standardLabel.font = [UIFont fontWithName:fontName size:self.fontSizeSlider.value];
    self.standardLabel.minimumFontSize = self.minFontSizeSlider.value;
    self.standardLabel.numberOfLines = (NSInteger)self.numberOfLinesSlider.value;
    self.standardLabel.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidthSwitch.on;
    self.standardLabel.baselineAdjustment = baselineAdjustment;
    self.standardLabel.lineBreakMode = lineBreakMode;
    self.standardLabel.text = text;
    
    self.numberOfLinesLabel.text = [NSString stringWithFormat:@"%.0f", self.numberOfLinesSlider.value];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%.0f", self.fontSizeSlider.value];
    self.minFontSizeLabel.text = [NSString stringWithFormat:@"%.0f", self.minFontSizeSlider.value];
}

#pragma mark Event callbacks

- (IBAction)updateLabels:(id)sender
{
    [self reloadData];
}

@end
