//
//  LayerPropertiesTestViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 8/31/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface LayerPropertiesTestViewController : HLSViewController {
@private
    UIView *_rectangleView;
    UIView *_topSubview;
    UIView *_bottomSubview;
    
    UISlider *_transformTxSlider;
    UILabel *_transformTxLabel;
    UISlider *_transformTySlider;
    UILabel *_transformTyLabel;
    UISlider *_transformTzSlider;
    UILabel *_transformTzLabel;
    UISlider *_transformRxSlider;
    UILabel *_transformRxLabel;
    UISlider *_transformRySlider;
    UILabel *_transformRyLabel;
    UISlider *_transformRzSlider;
    UILabel *_transformRzLabel;
    UISlider *_transformSxSlider;
    UILabel *_transformSxLabel;
    UISlider *_transformSySlider;
    UILabel *_transformSyLabel;
    UISlider *_transformSzSlider;
    UILabel *_transformSzLabel;
    
    UISlider *_sublayerTransformTxSlider;
    UILabel *_sublayerTransformTxLabel;
    UISlider *_sublayerTransformTySlider;
    UILabel *_sublayerTransformTyLabel;
    UISlider *_sublayerTransformTzSlider;
    UILabel *_sublayerTransformTzLabel;
    UISlider *_sublayerTransformRxSlider;
    UILabel *_sublayerTransformRxLabel;
    UISlider *_sublayerTransformRySlider;
    UILabel *_sublayerTransformRyLabel;
    UISlider *_sublayerTransformRzSlider;
    UILabel *_sublayerTransformRzLabel;
    UISlider *_sublayerTransformSxSlider;
    UILabel *_sublayerTransformSxLabel;
    UISlider *_sublayerTransformSySlider;
    UILabel *_sublayerTransformSyLabel;
    UISlider *_sublayerTransformSzSlider;
    UILabel *_sublayerTransformSzLabel;
    UISlider *_sublayerTransformSkewSlider;
    UILabel *_sublayerTransformSkewLabel;

    UISlider *_anchorPointXSlider;
    UILabel *_anchorPointXLabel;
    UISlider *_anchorPointYSlider;
    UILabel *_anchorPointYLabel;
    UISlider *_anchorPointZSlider;
    UILabel *_anchorPointZLabel;
    
    UISlider *_viewSublayerTransformSkewSlider;
    UILabel *_viewSublayerTransformSkewLabel;
}

@property (nonatomic, retain) IBOutlet UIView *rectangleView;
@property (nonatomic, retain) IBOutlet UIView *topSubview;
@property (nonatomic, retain) IBOutlet UIView *bottomSubview;

@property (nonatomic, retain) IBOutlet UISlider *transformTxSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformTxLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformTySlider;
@property (nonatomic, retain) IBOutlet UILabel *transformTyLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformTzSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformTzLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformRxSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformRxLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformRySlider;
@property (nonatomic, retain) IBOutlet UILabel *transformRyLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformRzSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformRzLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformSxSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformSxLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformSySlider;
@property (nonatomic, retain) IBOutlet UILabel *transformSyLabel;
@property (nonatomic, retain) IBOutlet UISlider *transformSzSlider;
@property (nonatomic, retain) IBOutlet UILabel *transformSzLabel;

@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformTxSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformTxLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformTySlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformTyLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformTzSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformTzLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformRxSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformRxLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformRySlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformRyLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformRzSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformRzLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformSxSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformSxLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformSySlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformSyLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformSzSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformSzLabel;
@property (nonatomic, retain) IBOutlet UISlider *sublayerTransformSkewSlider;
@property (nonatomic, retain) IBOutlet UILabel *sublayerTransformSkewLabel;

@property (nonatomic, retain) IBOutlet UISlider *anchorPointXSlider;
@property (nonatomic, retain) IBOutlet UILabel *anchorPointXLabel;
@property (nonatomic, retain) IBOutlet UISlider *anchorPointYSlider;
@property (nonatomic, retain) IBOutlet UILabel *anchorPointYLabel;
@property (nonatomic, retain) IBOutlet UISlider *anchorPointZSlider;
@property (nonatomic, retain) IBOutlet UILabel *anchorPointZLabel;

@property (nonatomic, retain) IBOutlet UISlider *viewSublayerTransformSkewSlider;
@property (nonatomic, retain) IBOutlet UILabel *viewSublayerTransformSkewLabel;

- (IBAction)settingsChanged:(id)sender;

- (IBAction)reset:(id)sender;

@end
