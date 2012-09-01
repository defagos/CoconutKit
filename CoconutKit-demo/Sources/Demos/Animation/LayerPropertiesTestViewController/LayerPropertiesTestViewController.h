//
//  LayerPropertiesTestViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 8/31/12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface LayerPropertiesTestViewController : HLSViewController {
@private
    UIView *m_rectangleView;
    UIView *m_topSubview;
    UIView *m_bottomSubview;
    
    UISlider *m_transformTxSlider;
    UILabel *m_transformTxLabel;
    UISlider *m_transformTySlider;
    UILabel *m_transformTyLabel;
    UISlider *m_transformTzSlider;
    UILabel *m_transformTzLabel;
    UISlider *m_transformRxSlider;
    UILabel *m_transformRxLabel;
    UISlider *m_transformRySlider;
    UILabel *m_transformRyLabel;
    UISlider *m_transformRzSlider;
    UILabel *m_transformRzLabel;
    UISlider *m_transformSxSlider;
    UILabel *m_transformSxLabel;
    UISlider *m_transformSySlider;
    UILabel *m_transformSyLabel;
    UISlider *m_transformSzSlider;
    UILabel *m_transformSzLabel;
    
    UISlider *m_sublayerTransformTxSlider;
    UILabel *m_sublayerTransformTxLabel;
    UISlider *m_sublayerTransformTySlider;
    UILabel *m_sublayerTransformTyLabel;
    UISlider *m_sublayerTransformTzSlider;
    UILabel *m_sublayerTransformTzLabel;
    UISlider *m_sublayerTransformRxSlider;
    UILabel *m_sublayerTransformRxLabel;
    UISlider *m_sublayerTransformRySlider;
    UILabel *m_sublayerTransformRyLabel;
    UISlider *m_sublayerTransformRzSlider;
    UILabel *m_sublayerTransformRzLabel;
    UISlider *m_sublayerTransformSxSlider;
    UILabel *m_sublayerTransformSxLabel;
    UISlider *m_sublayerTransformSySlider;
    UILabel *m_sublayerTransformSyLabel;
    UISlider *m_sublayerTransformSzSlider;
    UILabel *m_sublayerTransformSzLabel;
    UISlider *m_sublayerTransformSkewSlider;
    UILabel *m_sublayerTransformSkewLabel;

    UISlider *m_anchorPointXSlider;
    UILabel *m_anchorPointXLabel;
    UISlider *m_anchorPointYSlider;
    UILabel *m_anchorPointYLabel;
    UISlider *m_anchorPointZSlider;
    UILabel *m_anchorPointZLabel;
    
    UISlider *m_viewSublayerTransformSkewSlider;
    UILabel *m_viewSublayerTransformSkewLabel;
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
