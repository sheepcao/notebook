//
//  goalTableViewCell.h
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNChart.h"


@interface goalTableViewCell : UITableViewCell
@property (nonatomic, strong) PNPieChart *pieChart;
@property (nonatomic,strong) UIImageView *centerButton;
@property (nonatomic,strong) UILabel *doneLabel;
@property (nonatomic,strong) UILabel *totalLabel;
@property (nonatomic,strong) UILabel *themeLabel;

@property (nonatomic,strong) UIButton *timerButton;
@property (nonatomic,strong) UILabel *timerLabel;


-(void)returnTimer;
-(void)showTimer;
-(void)updatePieWith:(NSArray *)array byTime:(BOOL)isByTime centerColor:(UIColor *)myColor;

@end
