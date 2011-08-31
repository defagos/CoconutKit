//
//  OrientationClonerViewController.h
//  CoconutKit-demo
//
//  Created by Samuel Défago on 2/16/11.
//  Copyright 2011 Hortis. All rights reserved.
//

/**
 * A view controller which has different xibs for portrait and landscape modes
 */
@interface OrientationClonerViewController : HLSViewController <HLSOrientationCloner, HLSReloadable, UITextFieldDelegate> {
@private
    HLSTextField *m_textField;
    NSString *m_text;
    BOOL m_large;
}

- (id)initWithPortraitOrientation:(BOOL)portraitOrientation large:(BOOL)large;

@property (nonatomic, retain) IBOutlet HLSTextField *textField;
@property (nonatomic, assign, getter = isPortraitOrientation) BOOL portraitOrientation;
@property (nonatomic, assign, getter = isLarge) BOOL large;

@end
