//
//  SideMenuViewController.m
//  simpleFinance
//
//  Created by Eric Cao on 4/8/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "SideMenuViewController.h"
#import "global.h"
#import "MFSideMenu.h"
#import "summaryViewController.h"
#import "pieViewController.h"
#import "trendViewController.h"
#import "loginViewController.h"
#import "aboutViewController.h"

@interface SideMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSArray *menuArray;
@property (nonatomic, strong) NSArray *colorArray;

@end

@implementation SideMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //    NSLog(@"viewDidLoad ");
    
    self.menuArray = @[NSLocalizedString(@"事项总览",nil),NSLocalizedString(@"图表分解",nil),NSLocalizedString(@"近期走势",nil),NSLocalizedString(@"同 步 | 备 份",nil),NSLocalizedString(@"设置",nil)];
    self.colorArray = @[[UIColor colorWithRed:162/255.0f green:168/255.0f blue:148/255.0f alpha:1.0f], [UIColor colorWithRed:117/255.0f green:176/255.0f blue:144/255.0f alpha:1.0f],[UIColor colorWithRed:68/255.0f green:111/255.0f blue:121/255.0f alpha:1.0f], [UIColor colorWithRed:45/255.0f green:78/255.0f blue:81/255.0f alpha:1.0f],[UIColor colorWithRed:40/255.0f green:56/255.0f blue:71/255.0f alpha:1.0f]];
    
    UITableView *menuTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/5, SCREEN_HEIGHT)];
    menuTable.delegate = self;
    menuTable.dataSource = self;
    menuTable.scrollEnabled = NO;
    menuTable.backgroundColor = [UIColor clearColor];
    menuTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:menuTable];
    self.myMenuTable = menuTable;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"SideMenu"];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"SideMenu"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"sider->didReceiveMemoryWarning");
}



- (void)configUIAppearance{
    //    NSLog(@"sidebar config ui ");
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if ([showModel isEqualToString:@"上午"]) {
        self.myTextColor = TextColor0;
    }else if([showModel isEqualToString:@"夜间"]) {
        self.myTextColor = TextColor2;
    }
    NSString *backName;
    
    if (!showModel) {
        backName = @"上午1.png";
    }else
    {
        backName  = [NSString stringWithFormat:@"%@1.png",showModel];
    }
    
    if (!self.myBackImage)
    {
        self.myBackImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*2/5, SCREEN_HEIGHT)];
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
        [self.view addSubview:self.myBackImage];
        [self.view sendSubviewToBack:self.myBackImage];
        [self.view setNeedsDisplay];
    }else
    {
        [self.myBackImage setImage:[UIImage imageNamed:backName]];
    }
    [self.myMenuTable reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_HEIGHT/5;
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = @"sideCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *cellTitle  = [[UILabel alloc] init];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.backgroundColor = [UIColor clearColor];
        
        
        UIFontDescriptor *attributeFontDescriptorFirstPart = [UIFontDescriptor fontDescriptorWithFontAttributes:
                                                              @{UIFontDescriptorFamilyAttribute: @"HelveticaNeue",
                                                                UIFontDescriptorNameAttribute:@"HelveticaNeue",
                                                                UIFontDescriptorSizeAttribute: [NSNumber numberWithFloat: SCREEN_WIDTH/30]
                                                                }];
        [cellTitle setFrame:CGRectMake(tableView.frame.size.width/4, 0, tableView.frame.size.width/2, SCREEN_HEIGHT/5)];
        cellTitle.textColor = self.myTextColor;
        [cellTitle setFont:[UIFont fontWithDescriptor:attributeFontDescriptorFirstPart size:0.0f]];
        cellTitle.textAlignment = NSTextAlignmentCenter;
        [cell addSubview:cellTitle];
        
    }
    cellTitle.text = [NSString stringWithFormat:@"%@", self.menuArray[indexPath.row]];
    cell.backgroundColor = self.colorArray[indexPath.row];
    
    
    return cell;
}


#pragma mark -
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.userInteractionEnabled = NO;
    
    if (indexPath.row ==0) {
        NSLog(@"MFSideMenuStateClosing");
        
        summaryViewController *summaryVC = [[summaryViewController alloc] initWithNibName:@"summaryViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:summaryVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        NSLog(@"MFSideMenuStateClosed");
    }else if (indexPath.row ==1) {
        pieViewController *pieVC = [[pieViewController alloc] initWithNibName:@"pieViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:pieVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }
    else if(indexPath.row ==2)
    {
        trendViewController *trendVC = [[trendViewController alloc] initWithNibName:@"trendViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }
    else if (indexPath.row == 3) {
        loginViewController *loginVC = [[loginViewController alloc] initWithNibName:@"loginViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:loginVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        
    }else if(indexPath.row ==4)
    {
        aboutViewController *trendVC = [[aboutViewController alloc] initWithNibName:@"aboutViewController" bundle:nil];
        UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
        NSMutableArray *temp = [NSMutableArray arrayWithArray:navigationController.viewControllers];
        [temp addObject:trendVC];
        navigationController.viewControllers = temp;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}



@end
