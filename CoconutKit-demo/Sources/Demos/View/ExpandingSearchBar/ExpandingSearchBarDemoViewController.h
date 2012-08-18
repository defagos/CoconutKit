//
//  ExpandingSearchBarDemoViewController.h
//  CoconutKit-dev
//
//  Created by Samuel Défago on 11.06.12.
//  Copyright (c) 2012 Hortis. All rights reserved.
//

@interface ExpandingSearchBarDemoViewController : HLSViewController <HLSExpandingSearchBarDelegate> {
@private
    HLSExpandingSearchBar *m_searchBar1;
    HLSExpandingSearchBar *m_searchBar2;
    HLSExpandingSearchBar *m_searchBar3;
    UISwitch *m_animatedSwitch;
}

@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar1;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar2;
@property (nonatomic, retain) IBOutlet HLSExpandingSearchBar *searchBar3;

@property (nonatomic, retain) IBOutlet UISwitch *animatedSwitch;

- (IBAction)expandSearchBar1:(id)sender;
- (IBAction)collapseSearchBar1:(id)sender;

@end
