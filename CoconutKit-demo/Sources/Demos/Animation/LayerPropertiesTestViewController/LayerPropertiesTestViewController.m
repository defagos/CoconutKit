//
//  Copyright (c) Samuel Défago. All rights reserved.
//
//  License information is available from the LICENSE file.
//

#import "LayerPropertiesTestViewController.h"

@interface LayerPropertiesTestViewController ()

@property (nonatomic, weak) IBOutlet UIView *rectangleView;
@property (nonatomic, weak) IBOutlet UIView *topSubview;
@property (nonatomic, weak) IBOutlet UIView *bottomSubview;

@property (nonatomic, weak) IBOutlet UISlider *transformTxSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformTxLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformTySlider;
@property (nonatomic, weak) IBOutlet UILabel *transformTyLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformTzSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformTzLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformRxSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformRxLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformRySlider;
@property (nonatomic, weak) IBOutlet UILabel *transformRyLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformRzSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformRzLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformSxSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformSxLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformSySlider;
@property (nonatomic, weak) IBOutlet UILabel *transformSyLabel;
@property (nonatomic, weak) IBOutlet UISlider *transformSzSlider;
@property (nonatomic, weak) IBOutlet UILabel *transformSzLabel;

@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformTxSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformTxLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformTySlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformTyLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformTzSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformTzLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformRxSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformRxLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformRySlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformRyLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformRzSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformRzLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformSxSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformSxLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformSySlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformSyLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformSzSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformSzLabel;
@property (nonatomic, weak) IBOutlet UISlider *sublayerTransformSkewSlider;
@property (nonatomic, weak) IBOutlet UILabel *sublayerTransformSkewLabel;

@property (nonatomic, weak) IBOutlet UISlider *anchorPointXSlider;
@property (nonatomic, weak) IBOutlet UILabel *anchorPointXLabel;
@property (nonatomic, weak) IBOutlet UISlider *anchorPointYSlider;
@property (nonatomic, weak) IBOutlet UILabel *anchorPointYLabel;
@property (nonatomic, weak) IBOutlet UISlider *anchorPointZSlider;
@property (nonatomic, weak) IBOutlet UILabel *anchorPointZLabel;

@property (nonatomic, weak) IBOutlet UISlider *viewSublayerTransformSkewSlider;
@property (nonatomic, weak) IBOutlet UILabel *viewSublayerTransformSkewLabel;

@end

@implementation LayerPropertiesTestViewController

#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set zPositions so that layers can be seen not to be on the same plane when playing with sublayer transforms
    self.topSubview.layer.zPosition = 100.f;
    self.bottomSubview.layer.zPosition = -100.f;
    
    [self reset];
}

#pragma mark Orientation management

- (NSUInteger)supportedInterfaceOrientations
{
    return [super supportedInterfaceOrientations] & UIInterfaceOrientationMaskPortrait;
}

#pragma mark Localization

- (void)localize
{
    [super localize];
    
    self.title = NSLocalizedString(@"Layer properties test", nil);
}

#pragma mark Refreshing the screen

- (void)reloadData
{
    // Labels
    self.transformTxLabel.text = [NSString stringWithFormat:@"t_x = %.2f", self.transformTxSlider.value];
    self.transformTyLabel.text = [NSString stringWithFormat:@"t_y = %.2f", self.transformTySlider.value];
    self.transformTzLabel.text = [NSString stringWithFormat:@"t_z = %.2f", self.transformTzSlider.value];
    self.transformRxLabel.text = [NSString stringWithFormat:@"r_x = %.2f", self.transformRxSlider.value];
    self.transformRyLabel.text = [NSString stringWithFormat:@"r_y = %.2f", self.transformRySlider.value];
    self.transformRzLabel.text = [NSString stringWithFormat:@"r_z = %.2f", self.transformRzSlider.value];
    self.transformSxLabel.text = [NSString stringWithFormat:@"s_x = %.2f", self.transformSxSlider.value];
    self.transformSyLabel.text = [NSString stringWithFormat:@"s_y = %.2f", self.transformSySlider.value];
    self.transformSzLabel.text = [NSString stringWithFormat:@"s_z = %.2f", self.transformSzSlider.value];
    
    self.sublayerTransformTxLabel.text = [NSString stringWithFormat:@"t_x = %.2f", self.sublayerTransformTxSlider.value];
    self.sublayerTransformTyLabel.text = [NSString stringWithFormat:@"t_y = %.2f", self.sublayerTransformTySlider.value];
    self.sublayerTransformTzLabel.text = [NSString stringWithFormat:@"t_z = %.2f", self.sublayerTransformTzSlider.value];
    self.sublayerTransformRxLabel.text = [NSString stringWithFormat:@"r_x = %.2f", self.sublayerTransformRxSlider.value];
    self.sublayerTransformRyLabel.text = [NSString stringWithFormat:@"r_y = %.2f", self.sublayerTransformRySlider.value];
    self.sublayerTransformRzLabel.text = [NSString stringWithFormat:@"r_z = %.2f", self.sublayerTransformRzSlider.value];
    self.sublayerTransformSxLabel.text = [NSString stringWithFormat:@"s_x = %.2f", self.sublayerTransformSxSlider.value];
    self.sublayerTransformSyLabel.text = [NSString stringWithFormat:@"s_y = %.2f", self.sublayerTransformSySlider.value];
    self.sublayerTransformSzLabel.text = [NSString stringWithFormat:@"s_z = %.2f", self.sublayerTransformSzSlider.value];
    self.sublayerTransformSkewLabel.text = [NSString stringWithFormat:@"skew = %.4f", self.sublayerTransformSkewSlider.value];
    
    self.anchorPointXLabel.text = [NSString stringWithFormat:@"x = %.2f", self.anchorPointXSlider.value];
    self.anchorPointYLabel.text = [NSString stringWithFormat:@"y = %.2f", self.anchorPointYSlider.value];
    self.anchorPointZLabel.text = [NSString stringWithFormat:@"z = %.2f", self.anchorPointZSlider.value];
    
    self.viewSublayerTransformSkewLabel.text = [NSString stringWithFormat:@"skew = %.4f", self.viewSublayerTransformSkewSlider.value];
    
    // Layer transform
    CATransform3D rotationTransformX = CATransform3DMakeRotation(self.transformRxSlider.value, 1.f, 0.f, 0.f);
    CATransform3D rotationTransformY = CATransform3DMakeRotation(self.transformRySlider.value, 0.f, 1.f, 0.f);
    CATransform3D rotationTransformZ = CATransform3DMakeRotation(self.transformRzSlider.value, 0.f, 0.f, 1.f);
    CATransform3D scaleTransform = CATransform3DMakeScale(self.transformSxSlider.value,
                                                          self.transformSySlider.value,
                                                          self.transformSzSlider.value);
    CATransform3D translationTransform = CATransform3DMakeTranslation(self.transformTxSlider.value,
                                                                      self.transformTySlider.value,
                                                                      self.transformTzSlider.value);
    
    CATransform3D transform = CATransform3DConcat(rotationTransformX, rotationTransformY);
    transform = CATransform3DConcat(transform, rotationTransformZ);
    transform = CATransform3DConcat(transform, scaleTransform);
    transform = CATransform3DConcat(transform, translationTransform);
    self.rectangleView.layer.transform = transform;
    
    // Sublayer transform
    CATransform3D sublayerRotationTransformX = CATransform3DMakeRotation(self.sublayerTransformRxSlider.value, 1.f, 0.f, 0.f);
    CATransform3D sublayerRotationTransformY = CATransform3DMakeRotation(self.sublayerTransformRySlider.value, 0.f, 1.f, 0.f);
    CATransform3D sublayerRotationTransformZ = CATransform3DMakeRotation(self.sublayerTransformRzSlider.value, 0.f, 0.f, 1.f);
    CATransform3D sublayerScaleTransform = CATransform3DMakeScale(self.sublayerTransformSxSlider.value,
                                                                  self.sublayerTransformSySlider.value,
                                                                  self.sublayerTransformSzSlider.value);
    CATransform3D sublayerTranslationTransform = CATransform3DMakeTranslation(self.sublayerTransformTxSlider.value,
                                                                              self.sublayerTransformTySlider.value,
                                                                              self.sublayerTransformTzSlider.value);
    
    CATransform3D sublayerTransform = CATransform3DIdentity;
    sublayerTransform.m34 = self.sublayerTransformSkewSlider.value;
    sublayerTransform = CATransform3DConcat(sublayerTransform, sublayerRotationTransformX);
    sublayerTransform = CATransform3DConcat(sublayerTransform, sublayerRotationTransformY);
    sublayerTransform = CATransform3DConcat(sublayerTransform, sublayerRotationTransformZ);
    sublayerTransform = CATransform3DConcat(sublayerTransform, sublayerScaleTransform);
    sublayerTransform = CATransform3DConcat(sublayerTransform, sublayerTranslationTransform);
    self.rectangleView.layer.sublayerTransform = sublayerTransform;
    
    // Anchor point
    self.rectangleView.layer.anchorPoint = CGPointMake(self.anchorPointXSlider.value, self.anchorPointYSlider.value);
    self.rectangleView.layer.anchorPointZ = self.anchorPointZSlider.value;
    
    // View controller's view sublayer transform
    CATransform3D viewSublayerTransform = self.view.layer.sublayerTransform;
    viewSublayerTransform.m34 = self.viewSublayerTransformSkewSlider.value;
    self.view.layer.sublayerTransform = viewSublayerTransform;
}

- (void)reset
{
    self.transformTxSlider.value = 0.f;
    self.transformTySlider.value = 0.f;
    self.transformTzSlider.value = 0.f;
    self.transformRxSlider.value = 0.f;
    self.transformRySlider.value = 0.f;
    self.transformRzSlider.value = 0.f;
    self.transformSxSlider.value = 1.f;
    self.transformSySlider.value = 1.f;
    self.transformSzSlider.value = 1.f;
    
    self.sublayerTransformTxSlider.value = 0.f;
    self.sublayerTransformTySlider.value = 0.f;
    self.sublayerTransformTzSlider.value = 0.f;
    self.sublayerTransformRxSlider.value = 0.f;
    self.sublayerTransformRySlider.value = 0.f;
    self.sublayerTransformRzSlider.value = 0.f;
    self.sublayerTransformSxSlider.value = 1.f;
    self.sublayerTransformSySlider.value = 1.f;
    self.sublayerTransformSzSlider.value = 1.f;
    self.sublayerTransformSkewSlider.value = 0.f;
    
    self.anchorPointXSlider.value = 0.5f;
    self.anchorPointYSlider.value = 0.5f;
    self.anchorPointZSlider.value = 0.5f;
    
    self.viewSublayerTransformSkewSlider.value = 0.f;
    
    [self reloadData];
}

#pragma mark Action callbacks

- (IBAction)settingsChanged:(id)sender
{
    [self reloadData];
}

- (IBAction)reset:(id)sender
{
    [self reset];
}

@end
