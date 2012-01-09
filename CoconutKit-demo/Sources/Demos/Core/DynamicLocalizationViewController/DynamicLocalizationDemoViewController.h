//
//  DynamicLocalizationDemoViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 09.01.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface DynamicLocalizationDemoViewController : HLSViewController {
@private
    UIImageView *m_imageView;
    UISwitch *m_missingLocalizationVisibilitySwitch;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UISwitch *missingLocalizationVisibilitySwitch;

- (IBAction)toggleMissingLocalizationVisibility:(id)sender;

@end
