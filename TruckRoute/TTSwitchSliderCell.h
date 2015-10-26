//
//  TTSwitchSliderCell.h
//  TruckRoute
//
//  Created by Alpesh55 on 12/9/13.
//  Copyright (c) 2013 admin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTSwitchSliderCell : UITableViewCell
@property (nonatomic,retain)IBOutlet UILabel *titleLbl;
@property (nonatomic,retain)IBOutlet UILabel *subTitleLbl1;
@property (nonatomic,retain)IBOutlet UILabel *subTitleLbl2;
@property (nonatomic,retain)IBOutlet UISlider *pitchSlider;
@property (nonatomic,retain)IBOutlet UISlider *rateSlider;
@property (nonatomic,retain)IBOutlet UILabel *pitchLbl;
@property (nonatomic,retain)IBOutlet UILabel *rateLbl;
@property (nonatomic,retain)IBOutlet UISwitch *mySwitch;

@end
