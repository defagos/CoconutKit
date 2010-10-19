//
//  HLSSingleValuePickerViewController.h
//  nut
//
//  Created by Samuel Défago on 10/18/10.
//  Copyright 2010 Hortis. All rights reserved.
//

// Forward declarations
@protocol HLSSingleValuePickerViewControllerDelegate;

/**
 * Designated initializer: init
 */
@interface HLSSingleValuePickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate> {
@private
    NSArray *m_values;                  // contains NSString objects
    UIPickerView *m_pickerView;
    id<HLSSingleValuePickerViewControllerDelegate> m_delegate;
}

/**
 * Use this property to set the list of values to be displayed by the picker (array of NSString objects)
 */
@property (nonatomic, retain) NSArray *values;

// TODO: Currently not clean; must be called after the picker has been displayed to work; see HLSPageController
//       for how to set the initial value at any time after initialization (use member variable to store initial value)
- (void)setInitialValue:(NSString *)initialValue;

@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (nonatomic, assign) id<HLSSingleValuePickerViewControllerDelegate> delegate;

@end

@protocol HLSSingleValuePickerViewControllerDelegate <NSObject>

- (void)singleValuePickerViewController:(HLSSingleValuePickerViewController *)singleValuePickerViewController
                         hasPickedValue:(NSString *)value;

@optional

/**
 * If the values you are dealing with are codes with corresponding labels, then you can implement this method
 * to be able to set the label which must be displayed in the picker (the picker still works with the code
 * internally, and only return codes; the label is just used for display purposes). If this method is not
 * implemented by the delegate, then the code is displayed in the picker.
 */
- (NSString *)singleValuePickerViewController:(HLSSingleValuePickerViewController *)singleValuePickerController
                                labelForValue:(NSString *)value;

@end

