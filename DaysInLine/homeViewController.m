//
//  ViewController.m
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "homeViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "global.h"
#import "BottomView.h"
#import "RZTransitions.h"
#import "CommonUtility.h"
#import "pickerLabel.h"
#import "calendarViewController.h"
#import "constellationView.h"
#import "myLifeTableViewCell.h"
#import "myWorkTableViewCell.h"
#import "itemObj.h"
#import "itemDetailViewController.h"

@interface homeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,constellationDelegate>
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *todayItems;
@property (nonatomic,strong)  constellationView *myConstellView;
@property (nonatomic,strong) UIView *summaryView;

@property (nonatomic,strong) UIButton *addNewBtn;
@property (nonatomic,strong) UIButton *trackBtn;

@end

@implementation homeViewController
@synthesize summaryView;
@synthesize db;

- (void)configUIAppearance{
    NSLog(@"home config ui ");
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if ([showModel isEqualToString:@"上午"]) {
        self.myTextColor = TextColor0;
    }else if([showModel isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor2;
    }
    NSString *backName;
    if (!showModel) {
        backName = @"上午.png";
    }else
    {
        backName  = [NSString stringWithFormat:@"%@.png",showModel];
    }
    
    if (!self.myBackImage)
    {
        self.myBackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
        [self.view addSubview:self.myBackImage];
        [self.view sendSubviewToBack:self.myBackImage];
        [self.view setNeedsDisplay];
    }else
    {
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
    }
    
    [self.maintableView reloadData];
    [self configTextColor];
    
    
}

- (void)registerLuckChangedNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configLuckyText)
                                                 name:LuckChanged
                                               object:nil];
}

-(void)configTextColor
{
    [self.titleTextLabel setTextColor:self.myTextColor];
    [self.TimelineText setTextColor:self.myTextColor];
    [self.luckyText setTextColor:self.myTextColor];
    [self.constellationButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    
    
    [self.addNewBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    self.addNewBtn.layer.borderColor = self.myTextColor.CGColor;
    [self.trackBtn setTitleColor:self.myTextColor forState:UIControlStateNormal];
    self.trackBtn.layer.borderColor = self.myTextColor.CGColor;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerLuckChangedNotification];

    [self prepareData];

    
    constellationList = [[NSArray alloc]initWithObjects:@"白羊座     3.21-4.19",@"金牛座     4.20-5.20",@"双子座     5.21-6.21",@"巨蟹座     6.22-7.22",@"狮子座     7.23-8.22",@"处女座     8.23-9.22",@"天秤座     9.23-10.23",@"天蝎座     10.24-11.22",@"射手座     11.23-12.21",@"摩羯座     12.22-1.19",@"水瓶座     1.20-2.18",@"双鱼座     2.19-3.20",nil];
    constellationSelected = constellationList[0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    
    self.titleTextLabel.alpha = 1.0f;
    self.TimelineText.alpha = 0.0f;
    
    [self configLuckyText];
    [self configTextColor];

    
    self.navigationController.navigationBarHidden = YES;
    self.luckyText.alpha = 1.0f;
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
    
//    self.maintableView.backgroundColor = [UIColor colorWithPatternImage:self.myBackImage.image];

    self.maintableView.showsVerticalScrollIndicator = NO;
    self.maintableView.backgroundColor = [UIColor clearColor];
    self.maintableView.delegate = self;
    self.maintableView.dataSource = self;
    self.maintableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.maintableView.canCancelContentTouches = YES;
    self.maintableView.delaysContentTouches = YES;
    self.maintableView.bounces = NO;
    
    [self.view addSubview:self.maintableView];
    [self.view bringSubviewToFront:self.maintableView];
    
    [self configHeaderView];
    [self configBottomView];
    
    moneyLuckSpace = self.luckView.frame.size.height + self.luckView.frame.origin.y - topBarHeight;
//    if (IS_IPHONE_5) {
//        moneyLuckSpace = moneyLuckSpace-58;
//    }else if (IS_IPHONE_4_OR_LESS)
//    {
//        moneyLuckSpace = moneyLuckSpace-76;
//    }else if(IS_IPHONE_6P)
//    {
//        moneyLuckSpace = moneyLuckSpace-20;
//    }else
//    {
//        moneyLuckSpace = moneyLuckSpace-38;
//    }
//    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, moneyLuckSpace+ 15, 1, self.maintableView.frame.size.height)];
    midLine.backgroundColor = self.myTextColor;
    [self.maintableView addSubview:midLine];
    [self.maintableView sendSubviewToBack:midLine];

    
    if ([CommonUtility isSystemLangChinese]) {
        [self.maintableView addObserver: self forKeyPath: @"contentOffset" options: NSKeyValueObservingOptionNew context: nil];
    }else
    {
        self.TimelineText.alpha = 1.0f;
        self.titleTextLabel.alpha =0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
    [[RZTransitionsManager shared] setAnimationController:[[RZCirclePushAnimationController alloc] init]
                                       fromViewController:[self class]
                                                forAction:RZTransitionAction_PresentDismiss];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace*2/5 < 0.000001) {
        
        self.luckyText.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.titleTextLabel.alpha = 1.0 - self.maintableView.contentOffset.y/(moneyLuckSpace*1/3);
        self.TimelineText.alpha = 0.0f;
        
    }else if (self.maintableView.contentOffset.y > -0.0001 && self.maintableView.contentOffset.y - moneyLuckSpace < 0.000001)
    {
        self.TimelineText.alpha = (self.maintableView.contentOffset.y - moneyLuckSpace*2/5)/(moneyLuckSpace*3/5);
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
        
        
    }else if (self.maintableView.contentOffset.y < -0.00001)
    {
        [self.maintableView setContentOffset:CGPointMake(0, 0)];
    }else
    {
        self.TimelineText.alpha = 1.0f;
        self.titleTextLabel.alpha = 0.0f;
        self.luckyText.alpha = 0.0f;
    }
    
}

-(void)prepareData
{
    self.todayItems = [[NSMutableArray alloc] init];
    itemObj *oneItem = [[itemObj alloc] init];
    oneItem.itemCategory = @"水电煤";
    oneItem.itemDescription = @"快速华盛顿参加宁夏可刺激啊设备出口下降啊";
    oneItem.itemType = 1;
    
    itemObj *oneItem2 = [[itemObj alloc] init];
    oneItem2.itemCategory = @"旅游";
    oneItem2.itemDescription = @"快速的是法国今年的咖啡结核杆菌对话方式带来健康";
    oneItem2.itemType = 0;
    
    itemObj *oneItem3 = [[itemObj alloc] init];
    oneItem3.itemCategory = @"阅读";
    oneItem3.itemDescription = @"萨肯的杀菌开始的解放路弗兰克";
    oneItem3.itemType = 1;

    [self.todayItems addObject:oneItem];
    [self.todayItems addObject:oneItem2];
    [self.todayItems addObject:oneItem3];


    [self.maintableView reloadData];
    
}


- (IBAction)menuTapped:(id)sender {
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        if ([self.menuContainerViewController .rightMenuViewController isKindOfClass:[SideMenuViewController class]]) {
            SideMenuViewController *mySide = (SideMenuViewController *)self.menuContainerViewController .rightMenuViewController;
            mySide.myMenuTable.userInteractionEnabled = YES;
        }
    }];
    
}

- (void)menuStateEventOccurred:(NSNotification *)notification {
    
    if ([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidClose) {
        self.menuContainerViewController.panMode = MFSideMenuPanModeNone ;
        
    }else if([[[notification userInfo] objectForKey:@"eventType"] intValue] == MFSideMenuStateEventMenuDidOpen)
    {
        self.menuContainerViewController.panMode = MFSideMenuPanModeDefault ;
    }
}

-(void)configLuckyText
{
    
    NSString *Constellation = [[NSUserDefaults standardUserDefaults] objectForKey:@"Constellation"];
    if (!Constellation) {
        [self.luckyText makeText:@"设置星座，随时掌握财运 >"];
        return;
    }
    
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:Constellation ForView:self.luckyText];
    }
}

-(void)configHeaderView
{
    summaryView = [[UIView alloc] initWithFrame:CGRectMake(self.maintableView.frame.origin.x, 0, self.maintableView.frame.size.width, summaryViewHeight)];
    summaryView.backgroundColor = [UIColor clearColor];
    
    UIView *midLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 0.5, 15, 1, summaryViewHeight-15)];
    midLine.backgroundColor = self.myTextColor;
    [summaryView addSubview:midLine];

    myTextLabel *workLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(0, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [workLabel setText:NSLocalizedString(@"工作",nil)];
    UIView *bottomLine = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine.backgroundColor = self.myTextColor;
    [workLabel addSubview:bottomLine];
    [summaryView addSubview:workLabel];
    
    myTextLabel *lifeLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(summaryView.frame.size.width/2, 0, summaryView.frame.size.width/2, summaryViewHeight) andColor:self.myTextColor];
    [lifeLabel setText:NSLocalizedString(@"生活",nil)];
    UIView *bottomLine2 = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 11, workLabel.frame.size.width*3/4, 1)];
    bottomLine2.backgroundColor = self.myTextColor;
    [lifeLabel addSubview:bottomLine2];
    [summaryView addSubview:lifeLabel];
}


- (IBAction)showCalendar:(id)sender {
    
    calendarViewController *calendarVC = [[calendarViewController alloc] initWithNibName:@"calendarViewController" bundle:nil];
    [self.navigationController pushViewController:calendarVC animated:YES];
}

- (IBAction)configConstellation:(id)sender {
    
    constellationView *constellView = [[constellationView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    constellView.constellPicker.delegate = self;
    constellView.constellPicker.dataSource = self;
    constellView.constellDelegate = self;
    [constellView addGesture];
    [constellView.constellPicker selectRow:12*1000 inComponent:0 animated:NO];
    self.myConstellView = constellView;
    [self.view addSubview:constellView];
    
}
-(void)constellationChoose
{
    [MobClick event:@"setConstellation"];
    
    NSString *constellationOnly = [constellationSelected componentsSeparatedByString:@" "][0];
    
    [[NSUserDefaults standardUserDefaults] setObject:constellationOnly forKey:@"Constellation"];
    if ([CommonUtility isSystemLangChinese]) {
        [[CommonUtility sharedCommonUtility] fetchConstellation:constellationOnly ForView:self.luckyText];
    }
    
    if ([self.luckyText.text isEqualToString:@"设置星座，随时掌握财运 >"]) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [self.maintableView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }
    [self.myConstellView removeDimView];
    
}
-(void)cancelConstellation
{
    [self.myConstellView removeDimView];
}

-(void)configBottomView
{

    
    BottomView *bottomView = [[BottomView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-bottomHeight, SCREEN_WIDTH, bottomHeight)];
    bottomView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:bottomView];
    
    UIButton *addNewButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH/2-40, bottomHeight-20)];
    [addNewButton setTitle:NSLocalizedString(@"+ 新事项",nil) forState:UIControlStateNormal];
    [addNewButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    addNewButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    addNewButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    addNewButton.layer.borderColor = self.myTextColor.CGColor;
    addNewButton.layer.borderWidth = 0.75;
    self.addNewBtn = addNewButton;
    
    UIButton *trackButton = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+20, 10, SCREEN_WIDTH/2-40, bottomHeight-20)];
    [trackButton setTitle:NSLocalizedString(@"日常跟进",nil) forState:UIControlStateNormal];
    trackButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.0f];
    trackButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [trackButton setTitleColor:self.myTextColor forState:UIControlStateNormal];
    trackButton.layer.borderColor = self.myTextColor.CGColor;
    trackButton.layer.borderWidth = 0.75;
    self.trackBtn = trackButton;
    
    [addNewButton addTarget:self action:@selector(addNewItem:) forControlEvents:UIControlEventTouchUpInside];
    [trackButton addTarget:self action:@selector(trackItems:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:trackButton];
    [bottomView addSubview:addNewButton];
    

    
}
-(void)addNewItem:(UIButton *)sender
{
    
    [self presentViewController:[self nextAddNewItemViewController] animated:YES completion:nil];
    
}

- (UIViewController *)nextAddNewItemViewController
{
    itemDetailViewController* addItemVC = [[itemDetailViewController alloc] init];
    [addItemVC setTransitioningDelegate:[RZTransitionsManager shared]];
    addItemVC.isEditing = NO;
    NSDate *targetDay = [NSDate date];
    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    [dateFormatter1 setDateFormat:@"yyyy-MM-dd"];
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    dateFormatter1.calendar = cal;
    
    NSString *targetDate = [dateFormatter1 stringFromDate:targetDay];
    addItemVC.targetDate = targetDate;
    
    return addItemVC;
}


#pragma mark picker delegate
// pickerView 列数
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    pickerLabel *picker = [[pickerLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, 38)];
    [picker makeText:[constellationList objectAtIndex:(row%[constellationList count])]];
    return picker;
}



// pickerView 每列个数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [constellationList count] + 1000000;
}

// 每列宽度
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    
    return SCREEN_WIDTH-60;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 38;
}
// 返回选中的行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    constellationSelected = [constellationList objectAtIndex:(row%[constellationList count])];
}

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [constellationList objectAtIndex:(row%[constellationList count])];
}



#pragma mark -
#pragma mark Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if ([CommonUtility isSystemLangChinese]) {
            return moneyLuckSpace;
        }
        return 0;
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count){
        if (self.todayItems.count == 0) {
            return rowHeight;
        }else
        {
            return (self.maintableView.frame.size.height - summaryViewHeight - (rowHeight * self.todayItems.count));
        }
    }else
        return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if (section == 1 ) {
        return summaryViewHeight;
    }else
        return 0;
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        [self configConstellation:nil];
    }

}


#pragma mark -
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView             // Default is 1 if not implemented
{
    return 2;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0 )
    {
        return nil;
    }else if (section == 1)
    {
        return summaryView;
    }else
        return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else if(section == 1)
    {

        return self.todayItems.count<((self.maintableView.frame.size.height-summaryViewHeight)/rowHeight)?self.todayItems.count +1:self.todayItems.count ;
    }else
    {
        return self.todayItems.count;
    }
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        
        return cell;
        
    }else if(indexPath.section == 1 && indexPath.row == self.todayItems.count)
    {
        NSString *CellIdentifier = @"CellFill1";
        
        myLifeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myLifeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
        }
        
        return cell;
    }else 
    {
        NSString *category = @"";
        NSString *description = @"";
        int itemType = -1;
        if(self.todayItems.count>indexPath.row)
        {
            itemObj *oneItem = self.todayItems[indexPath.row];
            category = oneItem.itemCategory;
            description = oneItem.itemDescription;
            itemType = oneItem.itemType;
        }
        
        if (itemType == 0) {
            NSString *CellItemIdentifier = @"CellWork";
            myWorkTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
            if (cell == nil) {
                cell = [[myWorkTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                
            }
            [cell.category setText:category];
            [cell.note setText:description];
            [cell.itemTimeLabel setText:@"14:20 — 15:20"];
            
            [cell makeColor:category];
            [cell makeTextStyle];
            return cell;


        }else
        {
            NSString *CellItemIdentifier = @"CellLife";
            myLifeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellItemIdentifier];
            if (cell == nil) {
                cell = [[myLifeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellItemIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.backgroundColor = [UIColor clearColor];
                
            }
            [cell.category setText:category];
            [cell.note setText:description];
            [cell.itemTimeLabel setText:@"15:50 — 16:20"];

            [cell makeColor:category];
            [cell makeTextStyle];
            return cell;
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myLifeTableViewCell class]]) {
            myLifeTableViewCell *oneCell = (myLifeTableViewCell *)cell;
            CGFloat hiddenFrameHeight = scrollView.contentOffset.y + summaryViewHeight - cell.frame.origin.y;
            if (hiddenFrameHeight >= 0 || hiddenFrameHeight <= cell.frame.size.height) {
                [oneCell maskCellFromTop:hiddenFrameHeight];
            }
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView// called when scroll view grinds to a halt
{
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        //    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        [UIView animateWithDuration:0.35f animations:^(void){
            [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
        }];
    }else
        return;
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([CommonUtility isSystemLangChinese] && scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        //    if (scrollView.contentOffset.y<moneyLuckSpace && scrollView.contentOffset.y>0.001) {
        
        if (!decelerate) {
            [UIView animateWithDuration:0.35f animations:^(void){
                [scrollView setContentOffset:CGPointMake(0, moneyLuckSpace)];
            }];
        }else
            return;
        
    }else
        return;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
