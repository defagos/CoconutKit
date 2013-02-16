//
//  DynamicLocalizationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 09.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface DynamicLocalizationDemoViewController : HLSViewController {
@private
    UILabel *_coloredLabel;
    UIImageView *_imageView;
    UISwitch *_missingLocalizationVisibilitySwitch;
}

@property (nonatomic, retain) IBOutlet UILabel *coloredLabel;   // No outlet would be needed for localization purposes only, but 
                                                                // here we want to test background color changes
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UISwitch *missingLocalizationVisibilitySwitch;

- (IBAction)changeColor:(id)sender;
- (IBAction)toggleMissingLocalizationVisibility:(id)sender;

@end
