//
//  goalTableViewCell.m
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "goalTableViewCell.h"
#import "global.h"

@implementation goalTableViewCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        // adding pie===============================================================
        NSArray *items = @[[PNPieChartDataItem dataItemWithValue:80 color:PNRed
                                                     description:@"吃喝"],
                           [PNPieChartDataItem dataItemWithValue:20 color:PNBlue description:@"阅读"],
                           ];
        
        self.pieChart = [[PNPieChart alloc] initWithFrame:CGRectMake(20, 5.0, goalRowHeight-10, goalRowHeight - 10) items:items];

        [self.pieChart strokeChart];
        self.pieChart.displayAnimated = YES;
        self.pieChart.shouldHighlightSectorOnTouch = NO;
        self.pieChart.userInteractionEnabled = NO;
        self.pieChart.labelPercentageCutoff = 0.06;
        self.pieChart.duration = 0.38f;
        [self.contentView addSubview:self.pieChart];
        
        self.centerButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, goalRowHeight-30, goalRowHeight-30)];
        [self.centerButton setCenter:CGPointMake(self.pieChart.center.x, self.pieChart.center.y)];    ;

        self.centerButton.layer.cornerRadius = self.centerButton.frame.size.width/2;
        self.centerButton.layer.masksToBounds = NO;
        self.centerButton.layer.shadowOpacity = 1.0;
        self.centerButton.layer.shadowRadius = 1.5f;
        
        self.centerButton.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.centerButton.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        
//        [self.centerButton setBackgroundImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];

        [self.contentView addSubview:self.centerButton];
        
        self.doneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.centerButton.frame.size.width*3/4, self.centerButton.frame.size.height *3/5)];
        self.doneLabel.numberOfLines = 1;
        self.doneLabel.adjustsFontSizeToFitWidth = YES;
        self.doneLabel.textAlignment = NSTextAlignmentCenter;
        self.doneLabel.backgroundColor = [UIColor clearColor];
        self.doneLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
        [self.centerButton addSubview:self.doneLabel];
        
        self.totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,self.doneLabel.frame.size.height + 1, self.doneLabel.frame.size.width, self.centerButton.frame.size.height *2/5 - 1)];
        self.totalLabel.numberOfLines = 1;
        self.totalLabel.adjustsFontSizeToFitWidth = YES;
        self.totalLabel.textAlignment = NSTextAlignmentCenter;
        self.totalLabel.backgroundColor = [UIColor clearColor];
        self.totalLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:11.5];
        [self.centerButton addSubview:self.totalLabel];
        
        // adding  title =========================================================
        self.themeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChart.frame.size.width + self.pieChart.frame.origin.x + 10, rowHeight/2 - 15, 100, 30)];
        self.themeLabel.numberOfLines = 1;
        self.themeLabel.adjustsFontSizeToFitWidth = YES;
        self.themeLabel.textAlignment = NSTextAlignmentLeft;
        self.themeLabel.backgroundColor = [UIColor clearColor];
        self.themeLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [self.centerButton addSubview:self.themeLabel];
    
        // adding Timer button
        self.timerButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 32) -  rowHeight, 15 , rowHeight-30, rowHeight - 30)];
        [self.timerButton setImage:[UIImage imageNamed:@"pie"] forState:UIControlStateNormal];
        [self.timerButton setBackgroundColor:[UIColor darkGrayColor]];
        self.timerButton.layer.cornerRadius = self.timerButton.frame.size.width/2;
        self.timerButton.layer.masksToBounds = YES;
        self.timerButton.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.timerButton.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        
        self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.timerButton.frame.origin.x + 10, self.timerButton.center.y - 13, self.timerButton.frame.size.width - 20, 26)];
        self.timerLabel.numberOfLines = 1;
        self.timerLabel.adjustsFontSizeToFitWidth = YES;
        self.timerLabel.textAlignment = NSTextAlignmentCenter;
        self.timerLabel.backgroundColor = [UIColor darkGrayColor];
        self.timerLabel.font  = [UIFont fontWithName:@"Avenir-Medium" size:12.5];
        self.timerLabel.layer.cornerRadius = 6;
        self.timerLabel.layer.shadowColor =  [UIColor blackColor].CGColor;
        self.timerLabel.layer.shadowOffset = CGSizeMake(0.3f, 0.5f);
        [self.centerButton addSubview:self.timerLabel];
        [self.centerButton addSubview:self.timerButton];


      }
    
    return  self;
}

-(void)showTimer
{
    [self.timerLabel setText:@"00:00:00"];
    
    [UIView animateWithDuration:0.25f delay:0.01f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (self.timerLabel) {
            [self.timerLabel setFrame:CGRectMake(self.timerButton.frame.origin.x - 80, self.timerLabel.frame.origin.y, 80, self.timerLabel.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
    } ];
    
}
-(void)returnTimer
{
    [UIView animateWithDuration:0.25f delay:0.01f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (self.timerLabel) {
            [self.timerLabel setFrame:CGRectMake(self.timerButton.frame.origin.x + 10, self.timerButton.center.y - 13, self.timerButton.frame.size.width - 20, 26)];
        }
    } completion:nil ];
}

-(void)updatePieWith:(NSArray *)array byTime:(BOOL)isByTime
{
    [self.pieChart setItems:array];
    [self.pieChart recompute];
    [self.pieChart strokeChart];
    
    PNPieChartDataItem * itemDone = array[0];
    PNPieChartDataItem * itemUndone = array[1];

    if (isByTime) {
        [self.doneLabel setText:[NSString stringWithFormat:@"%.2f h",itemDone.value]];
        [self.totalLabel setText:[NSString stringWithFormat:@"%d h",(int)(itemDone.value + itemUndone.value)]];

    }else
    {
        [self.doneLabel setText:[NSString stringWithFormat:@"%d",(int)itemDone.value]];
        [self.totalLabel setText:[NSString stringWithFormat:@"%d",(int)(itemDone.value + itemUndone.value)]];
    }
}

@end
