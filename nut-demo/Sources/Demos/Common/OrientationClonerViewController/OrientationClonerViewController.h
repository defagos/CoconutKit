//
//  OrientationClonerViewController.h
//  nut-demo
//
//  Created by Samuel Défago on 2/16/11.
//  Copyright 2011 Hortis. All rights reserved.
//

@interface OrientationClonerViewController : HLSViewController <HLSOrientationCloner, HLSReloadable, UITextFieldDelegate> {
@private
    HLSTextField *m_textField;
    NSString *m_text;
    BOOL m_large;
}

- (id)initWithPortraitOrientation:(BOOL)portraitOrientation large:(BOOL)large;

@property (nonatomic, retain) IBOutlet HLSTextField *textField;

@end
