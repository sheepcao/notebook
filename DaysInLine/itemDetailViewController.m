//
//  itemDetailViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailViewController.h"
#import "global.h"
#import "topBarView.h"
#import "itemDetailTableViewCell.h"
#import "CommonUtility.h"
#import "RZTransitions.h"
#import "BottomView.h"
#import "categoryTableViewCell.h"
#import "categoryObject.h"

@interface itemDetailViewController ()<UITableViewDataSource,UITableViewDelegate,showPadDelegate>
{
    CGFloat bottomHeight;
}
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) UITableView *photoTable;
@property (nonatomic ,strong) UITableView *categoryTableView;
@property (nonatomic,strong) UIView *myDimView;

@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *workCategoryArray;
@property (nonatomic,strong) NSMutableArray *lifeCategoryArray;
@property (nonatomic ,strong) UISegmentedControl *moneyTypeSeg;

@end

@implementation itemDetailViewController
@synthesize db;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configTopbar];
    [self configDetailTable];
    [self configBottomView];
//    [self configButton];
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];
    


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.workCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:YES];
    self.lifeCategoryArray = [[CommonUtility sharedCommonUtility] prepareCategoryDataForWork:NO];
    [MobClick beginLogPageView:@"itemDetail"];
}

- (void)viewDidAppear:(BOOL)animated
{

    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"itemDetail"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareData
{
    //    db = [[CommonUtility sharedCommonUtility] db];
    //    if (![db open]) {
    //        NSLog(@"mainVC/Could not open db.");
    //        return;
    //    }
    
    //    FMResultSet *rs = [db executeQuery:@"select * from ITEMINFO where item_id = ?", self.currentItemID];
    //    while ([rs next]) {
    //
    //        self.categoryOnly  = [rs stringForColumn:@"item_category"];
    //        self.itemType = [rs intForColumn:@"item_type"];
    //        if (self.itemType == 0)
    //        {
    //            self.category = [NSLocalizedString(@"支出 > ",nil) stringByAppendingString:self.categoryOnly];
    //        }else
    //        {
    //            self.category = [NSLocalizedString(@"收入 > ",nil) stringByAppendingString:self.categoryOnly];
    //        }
    //
    //        self.itemDescription = [rs stringForColumn:@"item_description"];
    //        self.money = [NSString stringWithFormat:@"%.2f", [rs doubleForColumn:@"money"]];
    //
    //    }
    //
    //    [self.itemInfoTable reloadData];
    //    [self.itemMoneyLabel setText:self.money];
    //
    //    [db close];
    
}
-(void)configTopbar
{
    topBarView *topbar = [[topBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, topBarHeight)];
    topbar.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topbar];
    
    if (self.isEditing) {
        [topbar.titleLabel  setText:NSLocalizedString(@"事项详情",nil)];
    }else
    {
        [topbar.titleLabel  setText:NSLocalizedString(@"新增事项",nil)];
    }
    
    UIButton * closeViewButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 30, 40, 40)];
    closeViewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    closeViewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [closeViewButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    closeViewButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    //    [closeViewButton setTitle:@"取消" forState:UIControlStateNormal];
    [closeViewButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [closeViewButton addTarget:self action:@selector(closeVC) forControlEvents:UIControlEventTouchUpInside];
    closeViewButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:closeViewButton];
    
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-52, 30, 40, 40)];
    saveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    saveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [saveButton setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
    saveButton.imageEdgeInsets = UIEdgeInsetsMake(3.9, 3.9,3.9, 3.9);
    [saveButton setTitleColor:   normalColor forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveItem:) forControlEvents:UIControlEventTouchUpInside];
    saveButton.backgroundColor = [UIColor clearColor];
    [topbar addSubview:saveButton];
    
    
}

-(void)configBottomView
{
    CGFloat photoHeigh;
    if (IS_IPHONE_4_OR_LESS) {
        photoHeigh = 100;
    }else
    {
        photoHeigh = 135;
    }
    
    CGFloat f = (SCREEN_HEIGHT-SCREEN_WIDTH)*0.5;
    self.photoTable = [[UITableView alloc]initWithFrame:CGRectMake(0, f, photoHeigh, SCREEN_WIDTH) style:UITableViewStylePlain];
    [self.photoTable setCenter:CGPointMake(SCREEN_WIDTH/2, self.itemInfoTable.frame.size.height + self.itemInfoTable.frame.origin.y+photoHeigh-30)];
    self.photoTable.dataSource = self;
    self.photoTable.delegate = self;
    self.photoTable.transform = CGAffineTransformMakeRotation(-M_PI/2);
    self.photoTable.backgroundColor = [UIColor clearColor];
    self.photoTable.pagingEnabled = YES;
    self.photoTable.showsVerticalScrollIndicator = NO;
    self.photoTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIView *upline = [[UIView alloc] initWithFrame:CGRectMake(0,self.photoTable.frame.origin.y-1.5,self.photoTable.frame.size.width, 1.3)];
    upline.backgroundColor = normalColor;
    upline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    upline.layer.shadowColor = [UIColor blackColor].CGColor;
    upline.layer.shadowOpacity = 0.8;
    
    UIView *downline = [[UIView alloc] initWithFrame:CGRectMake(0,self.photoTable.frame.origin.y + self.photoTable.frame.size.height-1,self.photoTable.frame.size.width,1.2)];
    downline.backgroundColor = normalColor;
    downline.layer.shadowOffset = CGSizeMake(0.5, 0.6);
    downline.layer.shadowColor = [UIColor blackColor].CGColor;
    downline.layer.shadowOpacity = 0.8;
    [self.view addSubview:upline];
    [self.view addSubview:downline];

    [self.view addSubview:self.photoTable];
  
}


-(void)configDetailTable
{
    CGFloat height ;
    if (IS_IPHONE_4_OR_LESS) {
        height =50;
    }else
    {
        height =60;
    }
    
    self.itemInfoTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight + 5, SCREEN_WIDTH, height*5 )];
    self.itemInfoTable.showsVerticalScrollIndicator = NO;
    self.itemInfoTable.scrollEnabled = NO;
    self.itemInfoTable.backgroundColor = [UIColor clearColor];
    self.itemInfoTable.delegate = self;
    self.itemInfoTable.dataSource = self;
    self.itemInfoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.itemInfoTable];
    
}



-(void)showingModelOfHeight:(CGFloat)height andColor:(UIColor *)backColor forRow:(int)row
{
    
    UIView *dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    dimView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
    [self.view addSubview:dimView];
    self.myDimView = dimView;
    
    UIView *gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT- height)];
    gestureView.backgroundColor = [UIColor clearColor];
    [dimView addSubview:gestureView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [gestureView addGestureRecognizer:tap];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT, SCREEN_WIDTH-20, height)];
    contentView.tag = 100;
    contentView.backgroundColor = backColor;
    [dimView addSubview:contentView];
    contentView.layer.cornerRadius = 6;
    
    [UIView animateWithDuration:0.32f delay:0.15f options:UIViewAnimationOptionLayoutSubviews animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT- (height-10), contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:nil ];
  
    if (row == 0) {
        
        NSArray *segmentedArray = [[NSArray alloc]initWithObjects:NSLocalizedString(@"工作",nil),NSLocalizedString(@"生活",nil),nil];
        self.moneyTypeSeg = [[UISegmentedControl alloc]initWithItems:segmentedArray];
        self.moneyTypeSeg.frame = CGRectMake(SCREEN_WIDTH*2/7, 8, SCREEN_WIDTH*3/7, 30);
        self.moneyTypeSeg.tintColor =  TextColor2;
        self.moneyTypeSeg.selectedSegmentIndex = 0;
        [self.moneyTypeSeg addTarget:self action:@selector(segmentAction:)forControlEvents:UIControlEventValueChanged];  //添加委托方法
        [contentView addSubview:self.moneyTypeSeg];
        
        UITableView *categoryTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 48, SCREEN_WIDTH-20, contentView.frame.size.height-48)];
        categoryTable.showsVerticalScrollIndicator = YES;
        categoryTable.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        categoryTable.backgroundColor = [UIColor clearColor];
        categoryTable.delegate = self;
        categoryTable.dataSource = self;
        categoryTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        categoryTable.canCancelContentTouches = YES;
        categoryTable.delaysContentTouches = YES;
        self.categoryTableView = categoryTable;
        [contentView addSubview:categoryTable];
    }else
    {

    }

}
-(void)segmentAction:(UISegmentedControl *)Seg{
    NSInteger Index = Seg.selectedSegmentIndex;
    NSLog(@"Index %ld", (long)Index);
    [self.categoryTableView reloadData];
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.photoTable) {
        return tableView.frame.size.height;
    }else if (tableView == self.categoryTableView)
    {
         return ((int)(SCREEN_WIDTH/8));
    }else{
        if (IS_IPHONE_4_OR_LESS) {
            return 50;
        }else
        {
            return 60;
        }

    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.photoTable) {
        return 10;
    }else if (tableView == self.categoryTableView)
    {
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            return (self.workCategoryArray.count/4) + 1;
        }else
        {
            return (self.lifeCategoryArray.count/4) + 1;
        }

    }else
    return 5;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.photoTable) {
        NSString *CellIdentifier = @"CellPhoto";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
    }else if (tableView == self.categoryTableView)
    {
        NSString *CellIdentifier = @"categoryCell";
        
        categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[categoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.categoryDelegate = self;
            
        }
        
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        if (self.moneyTypeSeg.selectedSegmentIndex == 0) {
            if (self.workCategoryArray.count/4 > indexPath.row)
            {
                for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                    [tempArray addObject:self.workCategoryArray[i]];
                }
            }else
            {
                for (NSInteger  i = 4* indexPath.row; i < self.workCategoryArray.count; i++) {
                    [tempArray addObject:self.workCategoryArray[i]];
                }
            }
        }else
        {
            if (self.lifeCategoryArray.count/4 > indexPath.row)
            {
                for (NSInteger  i = 4* indexPath.row; i < 4* (indexPath.row + 1); i++) {
                    [tempArray addObject:self.lifeCategoryArray[i]];
                }
            }else
            {
                for (NSInteger  i = 4* indexPath.row; i < self.lifeCategoryArray.count; i++) {
                    [tempArray addObject:self.lifeCategoryArray[i]];
                }
            }
        }
        [cell contentWithCategories:tempArray];

        return cell;

    }
    NSString *CellIdentifier = @"itemInfoCell";
    itemDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[itemDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
    }
    [cell.leftText setTextColor:self.myTextColor];
    [cell.rightText setTitleColor:self.myTextColor forState:UIControlStateNormal];
    cell.padDelegate = self;
    cell.rightText.tag = indexPath.row + 10;
    
    switch (indexPath.row) {
        case 0:
            [cell.leftText  setText:NSLocalizedString(@" 主 题",nil)] ;
            [cell addExpend];
            if(self.category)
            {
                [cell.rightText setTitle:self.category forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"请选择" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 1:
            [cell.leftText setText: NSLocalizedString(@"开始时间",nil)];
            [cell addExpend];

            if(self.itemStartTime)
            {
                [cell.rightText setTitle:self.itemStartTime forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"请选择" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 2:
            [cell.leftText  setText: NSLocalizedString(@"结束时间",nil)];
            [cell addExpend];

            if(self.itemEndTime)
            {
                [cell.rightText setTitle:self.itemEndTime forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"请选择" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
        case 3:
            [cell.leftText  setText:NSLocalizedString(@"文字备注",nil)] ;
            if(self.itemDescription)
            {
                [cell.rightText setTitle:self.itemDescription forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"请输入" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal] ;
            }
            break;
            
        case 4:
            [cell.leftText  setText:NSLocalizedString(@"语音备注",nil)] ;
            if(self.soundName)
            {
                [cell.rightText setTitle:@"播放 录音" forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"按住 录音" forState:UIControlStateNormal];
            }
            [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];

            break;
            
            
        default:
            break;
    }
    return cell;
}

#pragma category cell delegate

-(void)categoryTap:(categoryButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"+ 新主题",nil)])
    {
        return;
    }
    
    self.category =sender.titleLabel.text;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [indexPaths addObject: indexPath];
    [self.itemInfoTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    [self dismissKeyboard];
    
}


#pragma mark cell delegate for show pad
-(void)showPad:(UIButton *)sender
{
    if (sender.tag - 10 == 0) {
        [self showingModelOfHeight:300 andColor:[UIColor colorWithRed:0.18f green:0.18f blue:0.18f alpha:1.0f] forRow:0];
    }
}

-(void)dismissKeyboard
{
    UIView *contentView = [self.myDimView viewWithTag:100];
    [UIView animateWithDuration:0.32f animations:^{
        if (contentView) {
            [contentView setFrame:CGRectMake(contentView.frame.origin.x, SCREEN_HEIGHT, contentView.frame.size.width, contentView.frame.size.height)];
        }
    } completion:^(BOOL isfinished){
        [self.myDimView removeFromSuperview];
    }];
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    if (tableView == self.itemInfoTable && indexPath.row == 0) {
//        
//        [self showingModelOfHeight:300];
//    }
//    
//}

-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
