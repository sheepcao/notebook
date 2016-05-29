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
#import "myMaskTableViewCell.h"

@interface homeViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,constellationDelegate>
@property (nonatomic,strong) FMDatabase *db;
@property (nonatomic,strong) NSMutableArray *todayItems;
@property (nonatomic,strong)  constellationView *myConstellView;
@end

@implementation homeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_IPHONE_6P) {
        bottomHeight = 65;
    }else
    {
        bottomHeight = bottomBar;
    }
    
    constellationList = [[NSArray alloc]initWithObjects:@"白羊座     3.21-4.19",@"金牛座     4.20-5.20",@"双子座     5.21-6.21",@"巨蟹座     6.22-7.22",@"狮子座     7.23-8.22",@"处女座     8.23-9.22",@"天秤座     9.23-10.23",@"天蝎座     10.24-11.22",@"射手座     11.23-12.21",@"摩羯座     12.22-1.19",@"水瓶座     1.20-2.18",@"双鱼座     2.19-3.20",nil];
    constellationSelected = constellationList[0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuStateEventOccurred:)
                                                 name:MFSideMenuStateNotificationEvent
                                               object:nil];
    
    self.titleTextLabel.alpha = 1.0f;
    self.TimelineText.alpha = 0.0f;
    
    [self configLuckyText];
    
    self.navigationController.navigationBarHidden = YES;
    self.luckyText.alpha = 1.0f;
    
    self.maintableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT- bottomHeight -topBarHeight) style:UITableViewStylePlain];
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
    }else
        return rowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }else if (section == 1) {
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
        UIView *summaryView = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.origin.x, 0, tableView.frame.size.width, summaryViewHeight)];
        summaryView.backgroundColor = [UIColor clearColor];
        
        UIView *midline = [[UIView alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2 -0.5, 10, 1, summaryViewHeight -10)];
        midline.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        [summaryView addSubview:midline];
        
        myTextLabel *workLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width/2, summaryViewHeight)];
        [workLabel setText:NSLocalizedString(@"工作",nil)];
        UIView *bottomLine = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 1, workLabel.frame.size.width*3/4, 1)];
        bottomLine.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        [workLabel addSubview:bottomLine];
        [summaryView addSubview:workLabel];
        
        myTextLabel *lifeLabel = [[myTextLabel alloc] initWithFrame:CGRectMake(tableView.frame.size.width/2, 0, tableView.frame.size.width/2, summaryViewHeight)];
        [lifeLabel setText:NSLocalizedString(@"生活",nil)];
        UIView *bottomLine2 = [[UIView alloc ] initWithFrame:CGRectMake(workLabel.frame.size.width/8, workLabel.frame.size.height - 1, workLabel.frame.size.width*3/4, 1)];
        bottomLine2.backgroundColor = [UIColor colorWithWhite:0.9f alpha:0.8];
        [lifeLabel addSubview:bottomLine2];
        [summaryView addSubview:lifeLabel];
        
        return summaryView;
    }else
        return nil;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 1;
    }else if(section == 1)
    {
        if (self.todayItems.count == 0) {
            if (IS_IPHONE_6P || IS_IPHONE_4_OR_LESS) {
                return ((self.maintableView.frame.size.height-summaryViewHeight )/rowHeight);
            }else
                return ((self.maintableView.frame.size.height-summaryViewHeight )/rowHeight)+1;
        }
        
        return self.todayItems.count<((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)?((self.maintableView.frame.size.height-summaryViewHeight - PieHeight)/rowHeight)+1:self.todayItems.count + 1;
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
        
    }else
    {// 补全table content 的实际长度，以便可以滑上去
        NSString *CellIdentifier = @"Cell";
        
        myMaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[myMaskTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
        return cell;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    for (UITableViewCell *cell in self.maintableView.visibleCells) {
        if ([cell isKindOfClass:[myMaskTableViewCell class]]) {
            myMaskTableViewCell *oneCell = (myMaskTableViewCell *)cell;
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
