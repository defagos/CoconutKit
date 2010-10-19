//
//  HLSSingleValuePicker.h
//  nut
//
//  Created by Samuel Défago on 10/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

#import "HLSSingleValuePickerViewController.h"

// Forward declarations
@protocol HLSSingleValuePickerDelegate;

/**
 * Designated initializer: initWithValues:
 */
@interface HLSSingleValuePicker : NSObject <HLSSingleValuePickerViewControllerDelegate> {
@private
    UIPopoverController *m_popoverController;
    HLSSingleValuePickerViewController *m_singleValuePickerViewController;
    id<HLSSingleValuePickerDelegate> m_delegate;
}

/**
 * This method expects an NSString array
 */
- (id)initWithValues:(NSArray *)values;

- (void)setInitialValue:(NSString *)initialValue;

@property (nonatomic, readonly, retain) UIPopoverController *popoverController;

@property (nonatomic, assign) id<HLSSingleValuePickerDelegate> delegate;

@end

@protocol HLSSingleValuePickerDelegate <NSObject>

- (void)singleValuePicker:(HLSSingleValuePicker *)singleValuePicker hasPickedValue:(NSString *)value;

@optional

/**
 * If the values you are dealing with are codes with corresponding labels, then you can implement this method
 * to be able to set the label which must be displayed in the picker (the picker still works with the code
 * internally, and only return codes; the label is just used for display purposes). If this method is not
 * implemented by the delegate, then the code is displayed in the picker.
 */
- (NSString *)singleValuePicker:(HLSSingleValuePicker *)singleValuePicker labelForValue:(NSString *)value;

@end
