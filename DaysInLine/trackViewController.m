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

@interface trackViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    CGFloat bottomHeight;

}
@property (nonatomic,strong) UITableView *goalsTable;
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *goalArray;
@property (nonatomic,strong) UIButton *myDeleteButton;

@end

@implementation trackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (IS_IPHONE_6P || IS_IPHONE_6) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    [self configTopbar];
    [self configDetailTable];
    [self configBottomView];
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
    oneGoal.goalTheme = @"阅读";
    oneGoal.byTime = 1;
    oneGoal.targetTime = 20;
    oneGoal.doneTime = 6;
    
    goalObj *twoGoal = [[goalObj alloc] init];
    twoGoal.goalType = 1;
    twoGoal.goalTheme = @"跑步";
    twoGoal.byTime = 0;
    twoGoal.targetCount = 10;
    twoGoal.doneCount = 6;
    
    [self.goalArray addObject:oneGoal];
    [self.goalArray addObject:twoGoal];
    
    
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
    [saveButton setImage:[UIImage imageNamed:@"trend"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(checkTrend) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    
}

-(void)checkTrend
{
    
}

-(void)closeVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configDetailTable
{

    
    self.goalsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight + 5, SCREEN_WIDTH, SCREEN_HEIGHT - topBarHeight - 5 - bottomHeight )];
    self.goalsTable.showsVerticalScrollIndicator = NO;
    self.goalsTable.scrollEnabled = YES;
    self.goalsTable.backgroundColor = [UIColor clearColor];
    self.goalsTable.delegate = self;
    self.goalsTable.dataSource = self;
    self.goalsTable.canCancelContentTouches = YES;
    self.goalsTable.delaysContentTouches = YES;
    self.goalsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.goalsTable];
    
}

-(void)configBottomView
{
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bottomView];
    
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/2-1, bottomHeight)];
    self.myDeleteButton = deleteButton;
    [deleteButton setTitle:NSLocalizedString(@"删减",nil) forState:UIControlStateNormal];
    [deleteButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    deleteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    deleteButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, bottomHeight)];
    [addNewButton setTitle:NSLocalizedString(@"添加",nil) forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [addNewButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    
    [deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
    [addNewButton addTarget:self action:@selector(addItem:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:deleteButton];
    [bottomView addSubview:addNewButton];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 1, 8, 1, bottomHeight-16)];
    midLine.backgroundColor = [UIColor whiteColor];
    [bottomView addSubview:midLine];
    
}

@end
