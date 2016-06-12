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

@interface trackViewController ()<UITableViewDelegate,UITableViewDataSource,showTimerDelegate,UITextFieldDelegate>
{
    CGFloat bottomHeight;
    UIButton *countingButton;
    NSInteger timerCount;
    CGFloat oldGoalNum;
    BOOL isOldGoalByTime;
    int updatingID;

}
@property (nonatomic,strong) UITableView *goalsTable;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *goalArray;
@property (nonatomic,strong) UIButton *myDeleteButton;
@property (nonatomic,strong) UIView *myDimView;
@property (nonatomic,strong) UILabel *myNewGoal;
@property (nonatomic,strong) UITextField *addingGoalField;

@end

@implementation trackViewController
{
    dispatch_source_t _timer;
}
@synthesize db;

-(void)pendingTimer
{
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

-(void)resigningActive:(NSNotification *)noti
{
    NSLog(@"pending------");
    [self pendingTimer];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resigningActive:) name:UIApplicationDidEnterBackgroundNotification object:nil];



    if (IS_IPHONE_6P || IS_IPHONE_6) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    _timer = [[CommonUtility sharedCommonUtility] myTimer];

    [self configTopbar];
    [self configDetailTable];
    [self configBottomView];

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
    
//    goalObj *oneGoal = [[goalObj alloc] init];
//    oneGoal.goalType = 0;
//    NSString *type = oneGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
//    oneGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type,@"阅读"];
//    oneGoal.themeOnly = @"阅读";
//    oneGoal.byTime = 1;
//    oneGoal.targetTime = 20000;
//    oneGoal.doneTime = 6000.3;
//    
//    goalObj *twoGoal = [[goalObj alloc] init];
//    twoGoal.goalType = 1;
//    NSString *type1 = twoGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
//    twoGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type1,@"培训"];
//    twoGoal.themeOnly = @"培训";
//    twoGoal.byTime = 0;
//    twoGoal.targetCount = 10;
//    twoGoal.doneCount = 10;
//    
//    goalObj *threeGoal = [[goalObj alloc] init];
//    threeGoal.goalType = 1;
//    NSString *type2 = threeGoal.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
//    threeGoal.goalTheme = [NSString stringWithFormat:@"%@ > %@",type2,@"旅游"];
//    threeGoal.themeOnly = @"旅游";
//    threeGoal.byTime = 0;
//    threeGoal.targetCount = 10;
//    threeGoal.doneCount = 6;
//    
//    [self.goalArray addObject:oneGoal];
//    [self.goalArray addObject:twoGoal];
//    [self.goalArray addObject:threeGoal];
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"mainVC/Could not open db.");
        return;
    }
    
    FMResultSet *rs = [db executeQuery:@"select * from GOALS where is_completed = ?", @0];
    while ([rs next]) {
        goalObj *oneItem = [[goalObj alloc] init];
        oneItem.goalID = [NSNumber numberWithInt: [rs intForColumn:@"goal_id"]];
        oneItem.themeOnly  = [rs stringForColumn:@"theme"];
        oneItem.goalType = [rs intForColumn:@"TYPE"];
        NSString *type = oneItem.goalType?NSLocalizedString(@"生活",nil):NSLocalizedString(@"工作",nil);
        oneItem.goalTheme = [NSString stringWithFormat:@"%@ > %@",type,oneItem.themeOnly];
        oneItem.byTime = [rs intForColumn:@"byTime"];
        if (oneItem.byTime) {
            oneItem.targetTime = [rs doubleForColumn:@"target_time"];
            oneItem.doneTime = [rs doubleForColumn:@"done_time"];
            if (oneItem.targetTime < oneItem.doneTime) {
                oneItem.doneTime = oneItem.targetTime;
            }
        }else
        {
            oneItem.targetCount = [rs intForColumn:@"target_count"];
            oneItem.doneCount = [rs intForColumn:@"done_count"];
            if (oneItem.targetCount < oneItem.doneCount) {
                oneItem.doneCount = oneItem.targetCount;
            }
        }
        [self.goalArray addObject:oneItem];
        
    }
    
    
    [self.goalsTable reloadData];
    [self performSelector:@selector(timerShow) withObject:nil afterDelay:0.05f];

}

-(void)viewDidDisappear:(BOOL)animated
{
    NSLog(@"viewDidDisappear");
    
    [self pendingTimer];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
    [self prepareGoalsData];

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
    [saveButton setTitleColor: normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(achieveList) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
}
-(void)achieveList
{
    NSLog(@"make a view controller for achieve list");
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

-(void)configBottomView
{
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:bottomView];
    
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 6, SCREEN_WIDTH/2, bottomHeight-12)];
    [addNewButton setTitle:NSLocalizedString(@"+ 新目标",nil) forState:UIControlStateNormal];
    [addNewButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.layer.borderColor = self.myTextColor.CGColor;
    addNewButton.layer.borderWidth = 0.9;
    
    [addNewButton addTarget:self action:@selector(addGoal) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:addNewButton];
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
    cell.finishButton.tag = indexPath.row;
    cell.goOnButton.tag = indexPath.row;

    
    if (timeDone>=timeTotal) {
        [cell.timerButton setHidden:YES];
        [cell.timerLabel setHidden:YES];
        [cell.finishButton setHidden:NO];
        [cell.goOnButton setHidden:NO];
    }else
    {
        [cell.timerButton setHidden:NO];
        [cell.timerLabel setHidden:NO];
        [cell.finishButton setHidden:YES];
        [cell.goOnButton setHidden:YES];
    }
    

    
    
    return cell;

}

#pragma mark cell delegate
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
-(void)archiveGoal:(UIButton *)sender
{
}
-(void)KeepingGoal:(UIButton *)sender
{
     [self showingModelOfHeight:SCREEN_HEIGHT*3/4 andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] forRow:sender.tag];
}

-(void)showingModelOfHeight:(CGFloat)height andColor:(UIColor *)backColor forRow:(NSInteger)row
{
    UIView *contentView;
    UIView *gestureView;
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dimView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
    [self.view addSubview:dimView];
    self.myDimView = dimView;
    gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- height)];
    gestureView.backgroundColor = [UIColor clearColor];
    gestureView.tag = 101;
    [dimView addSubview:gestureView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissDimView)];
    
    [gestureView addGestureRecognizer:tap];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH-20, height)];
    contentView.tag = 100;
    contentView.backgroundColor = backColor;
    [dimView addSubview:contentView];
    contentView.layer.cornerRadius = 10;
    
    
    [UIView animateWithDuration:0.2f delay:0.1f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT- (height-10), contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:nil ];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 5, 40, 35)];
    [cancelBtn setTitle:NSLocalizedString(@"取消",nil) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    cancelBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0];
    [contentView addSubview:cancelBtn];
    
    UIButton *selectBtn = [[UIButton alloc] initWithFrame:CGRectMake(contentView.frame.size.width-48, 5, 40, 35)];
    [selectBtn setTitle:NSLocalizedString(@"确定",nil) forState:UIControlStateNormal];
    [selectBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    selectBtn.titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    [contentView addSubview:selectBtn];
    selectBtn.tag = 20+row;
    
    [cancelBtn addTarget:self action:@selector(cancelSetting) forControlEvents:UIControlEventTouchUpInside];
    [selectBtn addTarget:self action:@selector(goalChoose:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UILabel *timeTitle = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 120, selectBtn.frame.size.height + 10, 100, 20)];
    [timeTitle setText:NSLocalizedString(@"已达:",nil)];
    [timeTitle setTextColor:[UIColor colorWithWhite:0.85f alpha:0.9f]];
    timeTitle.textAlignment = NSTextAlignmentCenter;
    timeTitle.font =  [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    [contentView addSubview:timeTitle];
    
    goalObj *oneGoal = self.goalArray[row];

    updatingID = [oneGoal.goalID intValue];
    
    NSString *doneNum = @"";
    UILabel *timeDone = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 , timeTitle.frame.origin.y, 100, 20)];
    if (oneGoal.byTime) {
        isOldGoalByTime = YES;
        doneNum = [NSString stringWithFormat:NSLocalizedString(@"%.2f 小时",nil),oneGoal.targetTime];
        oldGoalNum = oneGoal.targetTime;

    }else
    {
        isOldGoalByTime = NO;
        doneNum = [NSString stringWithFormat:NSLocalizedString(@"%d 次",nil),oneGoal.targetCount];
        oldGoalNum = oneGoal.targetCount;
    }
    
    [timeDone setText:doneNum];
    [timeDone setTextColor:[UIColor colorWithWhite:0.85f alpha:0.9f]];
    timeDone.textAlignment = NSTextAlignmentCenter;
    timeDone.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    [contentView addSubview:timeDone];
    
    UILabel *plusTitle = [[UILabel alloc] initWithFrame:CGRectMake(timeTitle.frame.origin.x , timeTitle.frame.origin.y+timeTitle.frame.size.height+20, timeTitle.frame.size.width, 20)];
    [plusTitle setText:NSLocalizedString(@"+",nil)];
    [plusTitle setTextColor:[UIColor colorWithWhite:0.85f alpha:0.9f]];
    plusTitle.textAlignment = NSTextAlignmentCenter;
    plusTitle.font =  [UIFont fontWithName:@"HelveticaNeue" size:25.0f];
    [contentView addSubview:plusTitle];
    
    UITextField *myAddingGoal= [[UITextField alloc] initWithFrame:CGRectMake(timeDone.frame.origin.x, timeDone.frame.origin.y + timeDone.frame.size.height + 20, timeDone.frame.size.width, 30)];
    myAddingGoal.textAlignment =NSTextAlignmentCenter;
    myAddingGoal.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    myAddingGoal.backgroundColor = [UIColor clearColor];
    myAddingGoal.textColor = [UIColor colorWithWhite:0.85f alpha:0.9f];
    myAddingGoal.keyboardType = UIKeyboardTypeNumberPad;
    myAddingGoal.returnKeyType = UIReturnKeyDone;
    myAddingGoal.delegate = self;
    myAddingGoal.tintColor = self.myTextColor;
    [contentView addSubview:myAddingGoal];
    self.addingGoalField = myAddingGoal;
    [self.addingGoalField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:myAddingGoal];

    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(plusTitle.frame.origin.x, plusTitle.frame.origin.y + plusTitle.frame.size.height + 10, 220, 1)];
    midLine.backgroundColor = self.myTextColor;
    [contentView addSubview:midLine];
    
    UILabel *newTitle = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 - 120, midLine.frame.origin.y + 10, 100, 20)];
    [newTitle setText:NSLocalizedString(@"进阶:",nil)];
    [newTitle setTextColor:[UIColor colorWithWhite:0.85f alpha:0.9f]];
    newTitle.textAlignment = NSTextAlignmentCenter;
    newTitle.font =  [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    [contentView addSubview:newTitle];
    
    UILabel *newGoal = [[UILabel alloc] initWithFrame:CGRectMake(contentView.frame.size.width/2 , midLine.frame.origin.y + 10, 100, 20)];
    [newGoal setTextColor:[UIColor colorWithWhite:0.85f alpha:0.9f]];
    newGoal.textAlignment = NSTextAlignmentCenter;
    newGoal.font =  [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    [contentView addSubview:newGoal];
    self.myNewGoal = newGoal;
    
}
-(void)dismissDimView
{
    [self.addingGoalField resignFirstResponder];
    
    UIView *contentView = [self.myDimView viewWithTag:100];
    [UIView animateWithDuration:0.32f animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        [self.myDimView removeFromSuperview];
    }];
}

-(void)cancelSetting
{
    [self dismissDimView];
}

-(void)goalChoose:(UIButton *)sender
{
    if (![self textFieldDidChange:nil]) {
        return;
    }
    CGFloat newGoalNum = [[self.myNewGoal.text componentsSeparatedByString:@" "][0] doubleValue];
    db = [[CommonUtility sharedCommonUtility] db];
    if (![db open]) {
        NSLog(@"addingGoal/Could not open db.");
        return;
    }
    
    if (isOldGoalByTime) {
        
        BOOL sql = [db executeUpdate:@"update GOALS set target_time = ? where goal_id = ?" ,[NSNumber numberWithFloat:newGoalNum],[NSNumber numberWithInt:updatingID]];
        if (!sql) {
            NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }
    }else
    {
        BOOL sql = [db executeUpdate:@"update GOALS set target_count = ? where goal_id = ?" ,[NSNumber numberWithInt:newGoalNum],[NSNumber numberWithInt:updatingID]];
        if (!sql) {
            NSLog(@"ERROR123: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }
    }

    
    [db close];
    
    [self prepareGoalsData];


    [self dismissDimView];
}

- (BOOL)textFieldDidChange:(NSNotification *)notification
{
    if ([self.addingGoalField.text doubleValue]<0.001)
    {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.animationType = MBProgressHUDAnimationZoom;
        hud.labelFont = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
        hud.mode = MBProgressHUDModeText;
        hud.labelText = NSLocalizedString(@"目标增量必须大于0",nil) ;
        [hud hide:YES afterDelay:1.5];
        return NO;
    }
    
    NSString *newGoalNum = @"";
    
    if (isOldGoalByTime )
    {
        newGoalNum = [NSString stringWithFormat:@"%.2f 小时",oldGoalNum + [self.addingGoalField.text doubleValue]];
    }else
    {
        newGoalNum = [NSString stringWithFormat:@"%d 次",(int)oldGoalNum + [self.addingGoalField.text intValue]];
    }
    [self.myNewGoal setText:newGoalNum];
    
    return YES;
}




@end
