//
//  trackViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 6/3/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "trackViewController.h"
#import "topBarView.h"
#import "global.h"
#import "BottomView.h"
#import "goalObj.h"
#import "goalTableViewCell.h"
#import "CommonUtility.h"
#import "goalDetailViewController.h"
#import "RZTransitions.h"

@interface trackViewController ()<UITableViewDelegate,UITableViewDataSource,showTimerDelegate>
{
    CGFloat bottomHeight;
    UIButton *countingButton;
    NSInteger timerCount;

}
@property (nonatomic,strong) UITableView *goalsTable;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *goalArray;
@property (nonatomic,strong) UIButton *myDeleteButton;

@end

@implementation trackViewController
{
    dispatch_source_t _timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_6P || IS_IPHONE_6) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    _timer = [[CommonUtility sharedCommonUtility] myTimer];
    
//    dispatch_queue_t  queue = dispatch_queue_create("com.sheepcao.app.timer", 0);
//    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//    dispatch_source_set_timer(_timer, dispatch_walltime(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC), 1ull * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
//    [self prepareGoalsData];
    [self configTopbar];
    [self configDetailTable];
    [self prepareGoalsData];

    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareGoalsData
{
    self.goalArray = [[NSMutableArray alloc] init];
    
    goalObj *oneGoal = [[goalObj alloc] init];
    oneGoal.goalType = 0;
    NSString *type = oneGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
    oneGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type,@"阅读"];
    oneGoal.themeOnly = @"阅读";
    oneGoal.byTime = 1;
    oneGoal.targetTime = 20000;
    oneGoal.doneTime = 6000.3;
    
    goalObj *twoGoal = [[goalObj alloc] init];
    twoGoal.goalType = 1;
    NSString *type1 = twoGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
    twoGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type1,@"培训"];
    twoGoal.themeOnly = @"培训";
    twoGoal.byTime = 0;
    twoGoal.targetCount = 10;
    twoGoal.doneCount = 6;
    
    goalObj *threeGoal = [[goalObj alloc] init];
    threeGoal.goalType = 1;
    NSString *type2 = threeGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
    threeGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type2,@"旅游"];
    threeGoal.themeOnly = @"旅游";
    threeGoal.byTime = 0;
    threeGoal.targetCount = 10;
    threeGoal.doneCount = 6;
    
    [self.goalArray addObject:oneGoal];
    [self.goalArray addObject:twoGoal];
    [self.goalArray addObject:threeGoal];
    
    [self.goalsTable reloadData];
    [self performSelector:@selector(timerShow) withObject:nil afterDelay:0.05f];

}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    if (countingButton) {
        
        goalTableViewCell *cell = (goalTableViewCell *)countingButton.superview ;
        
        NSString *timerCounts =  [NSString stringWithFormat:@"%ld", [cell timerCount]];
        NSDate *timeNow = [[CommonUtility sharedCommonUtility] timeNowDate];
        NSString *timerTheme = cell.themeLabel.text;
        NSDictionary *timerDict = @{@"timerTheme":timerTheme,@"timeNow":timeNow,@"timerCount":timerCounts};
        [[NSUserDefaults standardUserDefaults] setObject:timerDict forKey:Timer];
        dispatch_suspend(_timer);
        [cell returnTimer];
        countingButton = nil;

    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");

    
}

-(void)timerShow
{
    NSDictionary * timerDict = [[NSUserDefaults standardUserDefaults] objectForKey:Timer];
    if (timerDict) {
        
        NSInteger row = -1;
        for (int i = 0; i<self.goalArray.count; i++) {
            goalObj *oneGoal = self.goalArray[i];
            
            if ([oneGoal.goalTheme isEqualToString:[timerDict objectForKey:@"timerTheme"]]) {
                row = i;
                break;
            }
        }
        NSIndexPath *indexPath= [NSIndexPath indexPathForRow:row inSection:0];
        goalTableViewCell *cell = (goalTableViewCell *) [self.goalsTable cellForRowAtIndexPath:indexPath];
        NSDate *timeLast = [timerDict objectForKey:@"timeNow"];
        NSDate *timeNow = [[CommonUtility sharedCommonUtility] timeNowDate];
        NSInteger timeInterval = [[CommonUtility sharedCommonUtility] timeIntervalFromLastTime:timeLast ToCurrentTime:timeNow];
        
        NSInteger timerCountLast = [[timerDict objectForKey:@"timerCount"] integerValue];
        timerCount = timeInterval + timerCountLast;
        dispatch_source_set_event_handler(_timer, ^{
            NSLog(@"done on custom background queue");
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell timerPlus];
            });
        });
        
        dispatch_resume(_timer);
        [cell showTimerFrom:timerCount];
        countingButton = cell.timerButton;
    }

    

}
//
//
//-(void)viewDidLayoutSubviews
//{
//    
//    NSLog(@"viewDidLayoutSubviews");
//    
//    static dispatch_once_t predicate;
//    dispatch_once(&predicate, ^{
//        // some one-time task
//        NSDictionary * timerDict = [[NSUserDefaults standardUserDefaults] objectForKey:Timer];
//        if (timerDict) {
//            
//            NSInteger row = -1;
//            for (int i = 0; i<self.goalArray.count; i++) {
//                goalObj *oneGoal = self.goalArray[i];
//                
//                if ([oneGoal.goalTheme isEqualToString:[timerDict objectForKey:@"timerTheme"]]) {
//                    row = i;
//                    break;
//                }
//            }
//            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:row inSection:0];
//            goalTableViewCell *cell = (goalTableViewCell *) [self tableView:self.goalsTable cellForRowAtIndexPath:indexPath];
//            NSDate *timeLast = [timerDict objectForKey:@"timeNow"];
//            NSDate *timeNow = [[CommonUtility sharedCommonUtility] timeNowDate];
//            NSInteger timeInterval = [[CommonUtility sharedCommonUtility] timeIntervalFromLastTime:timeLast ToCurrentTime:timeNow];
//            
//            NSInteger timerCountLast = [[timerDict objectForKey:@"timerCount"] integerValue];
//            NSInteger timerCount = timeInterval + timerCountLast;
//            dispatch_source_set_event_handler(_timer, ^{
//                NSLog(@"done on custom background queue");
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [cell timerPlus];
//                });
//            });
//            
//            dispatch_resume(_timer);
//            [cell showTimerFrom:timerCount];
//            countingButton = cell.timerButton;
//            
//        }
//        
//    });
//    
// 
//}



-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    [topbar.titleLabel  setText:NSLocalizedString(@"目标跟踪",nil)];

    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 30, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 30, 40, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setImage:[UIImage imageNamed:@"add1"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(addGoal) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    
}

-(void)addGoal
{
    goalDetailViewController *newGoalVC = [[goalDetailViewController alloc] initWithNibName:@"goalDetailViewController" bundle:nil];
    [newGoalVC setTransitioningDelegate:[RZTransitionsManager shared]];
    newGoalVC.isEditing = NO;
    [self presentViewController:newGoalVC animated:YES completion:nil];
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configDetailTable
{
    
    self.goalsTable = [[UITableView alloc] initWithFrame:CGRectMake(16, topBarHeight + 5, SCREEN_WIDTH-32, SCREEN_HEIGHT - topBarHeight - 5 - 5 - bottomHeight )];
    self.goalsTable.showsVerticalScrollIndicator = NO;
    self.goalsTable.scrollEnabled = YES;
    self.goalsTable.backgroundColor = [UIColor clearColor];
    self.goalsTable.delegate = self;
    self.goalsTable.dataSource = self;
    self.goalsTable.canCancelContentTouches = YES;
    self.goalsTable.delaysContentTouches = YES;
    self.goalsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.goalsTable.layer.cornerRadius = 8;
    [self.view addSubview:self.goalsTable];
    
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return goalRowHeight;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"didSelectRowAtIndexPath:%ld",indexPath.row);
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.goalArray.count;
}

- (goalTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger itemID = -1;
    NSString *theme = @"";
    NSString *themeOnly = @"";

//    NSString *description = @"";
    int itemType = -1;
    BOOL isByTime = -1;
    
    double timeDone = -1.0f;
    double timeTotal = -1.0f;

    
    if(self.goalArray.count>indexPath.row)
    {
        goalObj *oneGoal = self.goalArray[indexPath.row];
        itemID = [oneGoal.goalID integerValue];
        theme = oneGoal.goalTheme;
        itemType = oneGoal.goalType;
        isByTime = oneGoal.byTime;
        themeOnly = oneGoal.themeOnly;
        
        if (isByTime) {
            timeDone = oneGoal.doneTime;
            timeTotal = oneGoal.targetTime;
        }else
        {
            timeDone = oneGoal.doneCount;
            timeTotal = oneGoal.targetCount;
        }
        
        
    }
    
    static NSString *CellItemIdentifier = @"CellGoal";
    goalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
    if (cell == nil) {
        cell = [[goalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.timerDelegate =self;
    }
    
    UIColor *categoryColor = [[CommonUtility sharedCommonUtility] categoryColor:themeOnly];
    
    NSArray *items = @[[PNPieChartDataItem dataItemWithValue:timeDone color:categoryColor
                                                 description:@""],
                       [PNPieChartDataItem dataItemWithValue:timeTotal - timeDone color:[[UIColor whiteColor] colorWithAlphaComponent:0.5f] description:@""]
                       ];
    
    [cell.themeLabel setText:theme];
    [cell updatePieWith:items byTime:isByTime centerColor:self.myTextColor];
    cell.timerButton.tag = indexPath.row;
    

    
    
    return cell;

}

-(void)timerMove:(UIButton *)sender
{

    if (countingButton && countingButton != sender) {
        return;
    }

    goalTableViewCell *cell = (goalTableViewCell *)sender.superview;

    if (cell.isTimerShown) {
//        dispatch_source_cancel(_timer);
        dispatch_suspend(_timer);
        [cell returnTimer];
        countingButton = nil;
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:Timer];

 
    }else
    {
        dispatch_source_set_event_handler(_timer, ^{
            NSLog(@"done on custom background queue");
            dispatch_async(dispatch_get_main_queue(), ^{
                [cell timerPlus];
            });
        });
        
        dispatch_resume(_timer);

        [cell showTimerFrom:0];
        countingButton = sender;
    }


}


@end
