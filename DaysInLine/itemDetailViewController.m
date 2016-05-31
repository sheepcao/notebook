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


@interface itemDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    CGFloat bottomHeight;
}
@property (nonatomic,strong) UITableView *itemInfoTable;
@property (nonatomic,strong) UITableView *photoTable;

@property (nonatomic,strong) FMDatabase *db;

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
    [MobClick beginLogPageView:@"itemDetail"];
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




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.photoTable) {
        return tableView.frame.size.height;
    }else
    {
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
    
    switch (indexPath.row) {
        case 0:
            [cell.leftText  setText:NSLocalizedString(@" 主 题",nil)] ;
            [cell addExpend];
            if(self.isEditing)
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

            if(self.isEditing)
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

            if(self.isEditing)
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
            if(self.isEditing)
            {
                [cell.rightText setTitle:self.description forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"请输入" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal] ;
            }
            break;
            
        case 4:
            [cell.leftText  setText:NSLocalizedString(@"语音备注",nil)] ;
            if(self.isEditing)
            {
                [cell.rightText setTitle:self.description forState:UIControlStateNormal];
                
            }else
            {
                [cell.rightText setTitle:@"按住 录音" forState:UIControlStateNormal];
                [cell.rightText setTitleColor:[self.myTextColor colorWithAlphaComponent:0.9f] forState:UIControlStateNormal];
            }
            break;
            
            
        default:
            break;
    }
    return cell;
}

-(void)configButton
{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, self.itemInfoTable.frame.origin.y + self.itemInfoTable.frame.size.height + 20, SCREEN_WIDTH/5,SCREEN_WIDTH/5 )];
    [deleteButton setImage:[UIImage imageNamed:@"trush"] forState:UIControlStateNormal];
    //    [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    [deleteButton addTarget:self action:@selector(deleteTap) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *editButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH/5-deleteButton.frame.size.width, deleteButton.frame.origin.y,deleteButton.frame.size.width,deleteButton.frame.size.height)];
    //    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    
    [editButton addTarget:self action:@selector(editTap) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:deleteButton];
    [self.view addSubview:editButton];
    
}

-(void)deleteTap
{
    NSInteger itemID = [self.currentItemID integerValue];
    if(itemID >=0)
    {
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"永久删除这笔账目?",nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"是的",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [MobClick event:@"deleteItem"];
            
            db = [[CommonUtility sharedCommonUtility] db];
            if (![db open]) {
                NSLog(@"mainVC/Could not open db.");
                return;
            }
            
            NSString *sqlCommand = [NSString stringWithFormat:@"delete from ITEMINFO where item_id=%ld",(long)itemID];
            BOOL sql = [db executeUpdate:sqlCommand];
            if (!sql) {
                NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }
            [db close];
            [self closeVC];
        }];
        
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"不",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:yesAction];
        [alert addAction:noAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}


-(void)closeVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
