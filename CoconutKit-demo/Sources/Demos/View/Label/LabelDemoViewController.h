//
//  LabelDemoViewController.h
//  CoconutKit-demo
//
//  Created by Joris Heuberger on 13.04.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface LabelDemoViewController : HLSViewController <UITextViewDelegate>{
@private
    HLSLabel *_label;
    UILabel *_standardLabel;
    
    UITextView *_textView;
    
    UISlider *_numberOfLinesSlider;
    UISlider *_fontSizeSlider;
    UISlider *_minFontSizeSlider;
    UISwitch *_adjustsFontSizeToFitWidthSwitch;
    UISegmentedControl *_verticalAlignmentSegmentedControl;
    
    UILabel *_numberOfLinesLabel;
    UILabel *_fontSizeLabel;
    UILabel *_minFontSizeLabel;
}

@property (nonatomic, retain) IBOutlet HLSLabel *label;
@property (nonatomic, retain) IBOutlet UILabel *standardLabel;

@property (nonatomic, retain) IBOutlet UITextView *textView;

@property (nonatomic, retain) IBOutlet UISlider *numberOfLinesSlider;
@property (nonatomic, retain) IBOutlet UISlider *fontSizeSlider;
@property (nonatomic, retain) IBOutlet UISlider *minFontSizeSlider;
@property (nonatomic, retain) IBOutlet UISwitch *adjustsFontSizeToFitWidthSwitch;
@property (nonatomic, retain) IBOutlet UISegmentedControl *verticalAlignmentSegmentedControl;

@property (nonatomic, retain) IBOutlet UILabel *numberOfLinesLabel;
@property (nonatomic, retain) IBOutlet UILabel *fontSizeLabel;
@property (nonatomic, retain) IBOutlet UILabel *minFontSizeLabel;

- (IBAction)updateView:(id)sender;
- (IBAction)changeFontSize:(id)sender;

@end
