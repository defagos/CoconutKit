//
//  LabelDemoViewController.m
//  CoconutKit-demo
//
//  Created by Joris Heuberger on 13.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

#import "LabelDemoViewController.h"

@interface LabelDemoViewController ()

- (void)updateLabel;
- (void)updateView;

@end

@implementation LabelDemoViewController

#pragma mark Object creation and destruction

- (id)init
{
    if ((self = [super initWithNibName:[self className] bundle:nil])) {
        
    }
    return self;
}

- (void)releaseViews
{
    [super releaseViews];
    
    self.label = nil;
    self.standardLabel = nil;
    self.textView = nil;
    self.numberOfLinesSlider = nil;
    self.fontSizeSlider = nil;
    self.minFontSizeSlider = nil;
    self.adjustsFontSizeToFitWidthSwitch = nil;
    self.verticalAlignmentSegmentedControl = nil;
    self.numberOfLinesLabel = nil;
    self.fontSizeLabel = nil;
    self.minFontSizeLabel = nil;
}

#pragma mark Accessors and mutators

@synthesize label = _label;

@synthesize standardLabel = _standardLabel;

@synthesize textView = _textView;

@synthesize numberOfLinesSlider = _numberOfLinesSlider;

@synthesize fontSizeSlider = _fontSizeSlider;

@synthesize minFontSizeSlider = _minFontSizeSlider;

@synthesize adjustsFontSizeToFitWidthSwitch = _adjustsFontSizeToFitWidthSwitch;

@synthesize verticalAlignmentSegmentedControl = _verticalAlignmentSegmentedControl;

@synthesize numberOfLinesLabel = _numberOfLinesLabel;

@synthesize fontSizeLabel = _fontSizeLabel;

@synthesize minFontSizeLabel = _minFontSizeLabel;

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateView];
    [self updateLabel];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%.0f", self.fontSizeSlider.value];    
}

- (void)updateLabel
{
    // HLSLabel
    self.label.font = [UIFont fontWithName:[self.label.font fontName] size:self.fontSizeSlider.value];
    self.label.minimumFontSize = self.minFontSizeSlider.value;
    self.label.numberOfLines = (int)self.numberOfLinesSlider.value;
    self.label.verticalAlignment = self.verticalAlignmentSegmentedControl.selectedSegmentIndex;
    self.label.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidthSwitch.on;
        
    self.label.text = self.textView.text;
    
    // UILabel
    self.standardLabel.font = [UIFont fontWithName:[self.label.font fontName] size:self.fontSizeSlider.value];
    self.standardLabel.minimumFontSize = self.minFontSizeSlider.value;
    self.standardLabel.numberOfLines = (int)self.numberOfLinesSlider.value;
    self.standardLabel.adjustsFontSizeToFitWidth = self.adjustsFontSizeToFitWidthSwitch.on;
    
    self.standardLabel.text = self.textView.text;
}

- (void)updateView
{    
    self.numberOfLinesSlider.value = self.label.numberOfLines;
    self.minFontSizeSlider.value = self.label.minimumFontSize;
    self.adjustsFontSizeToFitWidthSwitch.on = self.label.adjustsFontSizeToFitWidth;
    self.verticalAlignmentSegmentedControl.selectedSegmentIndex = self.label.verticalAlignment;
    self.numberOfLinesLabel.text = [NSString stringWithFormat:@"%d", self.label.numberOfLines];
    self.minFontSizeLabel.text = [NSString stringWithFormat:@"%.0f", self.label.minimumFontSize];
}

#pragma mark Orientation management

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (! [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        return NO;
    }
    
    return YES;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Label", @"Label");
    self.textView.text = NSLocalizedString(@"This text is too long to be displayed on 2 lines in a UILabel", 
                                           @"This text is too long to be displayed on 2 lines in a UILabel");
    
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Top", @"Top") forSegmentAtIndex:0];
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Middle", @"Middle") forSegmentAtIndex:1];
    [self.verticalAlignmentSegmentedControl setTitle:NSLocalizedString(@"Bottom", @"Bottom") forSegmentAtIndex:2];
    
    [self updateLabel];
}

#pragma mark UITextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateLabel];
    [self updateView];
}

#pragma mark Event callbacks

- (IBAction)updateView:(id)sender
{
    [self updateLabel];
    [self updateView];
}

- (IBAction)changeFontSize:(id)sender;
{
    [self updateLabel];
    [self updateView];
    self.fontSizeLabel.text = [NSString stringWithFormat:@"%.0f", self.fontSizeSlider.value];
}

@end
