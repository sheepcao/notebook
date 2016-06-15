//
//  AppDelegate.m
//  DaysInLine
//
//  Created by Eric Cao on 5/27/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "AppDelegate.h"
#import "homeViewController.h"
#import "SideMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "CommonUtility.h"
#import "OpenShareHeader.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
@interface AppDelegate ()
@property (nonatomic,strong) FMDatabase *db;

@end

@implementation AppDelegate
@synthesize db;


- (homeViewController *)demoController {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    homeViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"homeViewController"];
    
    return vc;
}

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self demoController]];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }

    
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (!autoSwitchString) {
        [[NSUserDefaults standardUserDefaults] setObject:@"on" forKey:AUTOSWITCH];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SideMenuViewController *rightMenuViewController = [[SideMenuViewController alloc] init];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:[self navigationController]
                                                    leftMenuViewController:nil
                                                    rightMenuViewController:rightMenuViewController];
    container.menuWidth = SCREEN_WIDTH*2/5;
    self.window.rootViewController = container;
    
    [self initDB];
    [self judgeTimeFrame];
    [self configShare];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    if ([CommonUtility isSystemLangChinese]) {
        [self loadLuckInfoFromServer];
    }else
    {
        NSLog(@"不是中文");
    }
    
    [self.window makeKeyAndVisible];
    
    [[CommonUtility sharedCommonUtility] createTimer];
    

    return YES;
}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    //第二步：添加回调
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }else if ([CommonUtility myContainsStringFrom:[NSString stringWithFormat:@"%@",url]  forSubstring:@"fb"] )
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                              openURL:url
                                                    sourceApplication:sourceApplication
                                                           annotation:annotation];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [self judgeTimeFrame];
    application.applicationIconBadgeNumber = 0;

    NSLog(@"applicationWillEnterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    if ([CommonUtility isSystemLangChinese]) {
        [self loadLuckInfoFromServer];
    }else
    {
        NSLog(@"不是中文");
    }
    

}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification{
    
    // 图标上的数字减1
    
    application.applicationIconBadgeNumber = 0;
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


-(void)initDB
{


    db = [[CommonUtility sharedCommonUtility] db];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    NSString *createCategoryTable = @"CREATE TABLE IF NOT EXISTS CATEGORYINFO (category_id INTEGER PRIMARY KEY AUTOINCREMENT,category_name TEXT,category_type INTEGER,color_R Double,color_G Double,color_B Double, is_deleted INTEGER DEFAULT 0)";
    NSString *createLuckTable = @"CREATE TABLE IF NOT EXISTS MONEYLUCK (luck_id INTEGER PRIMARY KEY AUTOINCREMENT,week_sequence INTEGER,luck_Cn TEXT,luck_En TEXT,start_date TEXT,content TEXT, constellation TEXT)";
    NSString *createColorTable = @"CREATE TABLE IF NOT EXISTS COLORINFO (color_id INTEGER PRIMARY KEY AUTOINCREMENT,color_R Double,color_G Double,color_B Double, used_count INTEGER)";
    
    NSString *createEvent = @"CREATE TABLE IF NOT EXISTS EVENTS (eventID INTEGER PRIMARY KEY AUTOINCREMENT,TYPE INTEGER,TITLE TEXT,mainText TEXT,income REAL,expend REAL,date Date,startTime REAL,endTime REAL,distance TEXT,label TEXT,remind TEXT,startArea INTEGER,photoDir TEXT)";
    
    NSString *createCollect = @"CREATE TABLE IF NOT EXISTS collection (collectionID INTEGER PRIMARY KEY AUTOINCREMENT,eventID INTEGER)";
    NSString *createPassword = @"CREATE TABLE IF NOT EXISTS passwordVar (varName TEXT PRIMARY KEY,value TEXT)";
    NSString *goalTable = @"CREATE TABLE IF NOT EXISTS GOALS (goal_id INTEGER PRIMARY KEY AUTOINCREMENT,TYPE INTEGER,theme TEXT,byTime INTEGER,target_time REAL,done_time REAL,target_count INTEGER,done_count INTEGER,start_date TEXT,finish_date TEXT,remind_time TEXT,remind_days TEXT,is_completed INTEGER)";

    
    [db executeUpdate:createCategoryTable];
    [db executeUpdate:createLuckTable];
    [db executeUpdate:createColorTable];
    [db executeUpdate:createEvent];
    [db executeUpdate:createCollect];
    [db executeUpdate:createPassword];
    [db executeUpdate:goalTable];

    
    NSString *selectEVENTSCount = @"select * from EVENTS";
    FMResultSet *rs1 = [db executeQuery:selectEVENTSCount];
    if ([rs1 next]) {
    }else
    {
        FMResultSet *rs2 = [db executeQuery:@"select * from EVENT"];
        while ([rs2 next]) {
            BOOL sql =  [db executeUpdate:@"insert into EVENTS (eventID,TYPE,TITLE,mainText,income,expend,date,startTime,endTime,distance,label,remind,startArea,photoDir) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:[rs2 intForColumnIndex:0]],[NSNumber numberWithInt:[rs2 intForColumnIndex:1]],[rs2 stringForColumnIndex:2],[rs2 stringForColumnIndex:3],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:4]],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:5]],[rs2 stringForColumnIndex:6],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:7]],[NSNumber numberWithDouble:[rs2 doubleForColumnIndex:8]],[rs2 stringForColumnIndex:9],[rs2 stringForColumnIndex:10],[rs2 stringForColumnIndex:11],[NSNumber numberWithInt:[rs2 intForColumnIndex:12]],[rs2 stringForColumnIndex:13]];
            if (!sql) {
                NSLog(@"CATEGORY ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
            }
        }
        
        BOOL sql2 =  [db executeUpdate:@"DROP TABLE EVENT"];
        if (!sql2) {
            NSLog(@"DROP ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
        }

    }
    



    //第一次启动，加载默认类别和颜色
    int categoryCount;
    NSString *selectCategoryCount = @"select count (*) from CATEGORYINFO";
    FMResultSet *rs = [db executeQuery:selectCategoryCount];
    if ([rs next]) {
        categoryCount = [rs intForColumnIndex:0];
    }
    if (categoryCount == 0) {
        [self insertDefaultCategoryToDB:db];
    }
    
    int colorCount;
    NSString *selectColorCount = @"select count (*) from COLORINFO";
    FMResultSet *rsColor = [db executeQuery:selectColorCount];
    if ([rsColor next]) {
        colorCount = [rsColor intForColumnIndex:0];
    }
    if (colorCount == 0) {
        [self insertDefaultColorToDB:db];
    }
    
    int goalCount;
    NSString *selectGoalCount = @"select count (*) from GOALS";
    FMResultSet *rsGoal = [db executeQuery:selectGoalCount];
    if ([rsColor next]) {
        goalCount = [rsGoal intForColumnIndex:0];
    }
    if (colorCount == 0) {
        [self insertDefaultGOALSToDB:db];
    }
    
    
    [db close];
}


-(void)judgeTimeFrame
{
//    NSLog(@"judgeTimeFrame");
    
    NSString *autoSwitchString = [[NSUserDefaults standardUserDefaults] objectForKey:AUTOSWITCH];
    if (![autoSwitchString isEqualToString:@"on"])
    {
        return;
    }
    
    NSCalendar *cal = [[NSCalendar alloc]
                       initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [NSDate date];
    NSInteger hour;
    if (SYSTEM_VERSION_LESS_THAN(iOS8_0)) {
        NSDateComponents *components = [cal components:NSCalendarUnitHour fromDate:date];
        hour = components.hour;
    }else
    {
        hour = [cal component:NSCalendarUnitHour fromDate:date];
    }
    
    if (hour>6 &&hour<18) {
        [[NSUserDefaults standardUserDefaults] setObject:@"上午" forKey:SHOWMODEL];
    }else
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"夜间" forKey:SHOWMODEL];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeChanged  object:nil];
    
    
}

-(void)loadLuckInfoFromServer
{
    
//    NSLog(@"loadLuckInfoFromServer");
    
    NSDate *dateNow = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc]  initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:dateNow];
    NSInteger dayofweek = [[gregorian components:NSCalendarUnitWeekday fromDate:dateNow] weekday];
    
    [components setDay:([components day] - ((dayofweek) - 1))];// for beginning of the week.
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:components];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.calendar = gregorian;
    [dateFormat setDateFormat:@"yyyy年MM月dd日"];
    NSString *dateString= [dateFormat stringFromDate:beginningOfWeek];
    
    if (![db open]) {
        NSLog(@"Could not open db.");
        return;
    }
    
    NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",dateString];
    
    FMResultSet *rs = [db executeQuery:selectLuckExist];
    if ([rs next]) {
        //        NSString *luckString = [rs stringForColumn:@"content"];
        //        [[NSUserDefaults standardUserDefaults] setObject:luckString forKey:@"luckString"];
        [db close];
    }else
    {
        [db close];
        
        NSDictionary *parameters = @{@"tag": @"fetch_luckinfo",@"start_date":dateString};
        
        [[CommonUtility sharedCommonUtility] httpGetUrlNoToken:constellationService params:parameters success:^(NSDictionary *success){
            
            if ([success objectForKey:@"success"] == 0) {
                return ;
            }
            
            NSArray *nameArray = [success objectForKey:@"name"];
            NSArray *contentArray = [success objectForKey:@"content"];
            NSString *startDate = [success objectForKey:@"start_date"][0];
            NSString *week = [success objectForKey:@"week"][0];
            
            
            NSLog(@"%@",startDate);
            
            NSString *selectLuckExist = [NSString stringWithFormat:@"select * from MONEYLUCK where start_date = '%@'",startDate];
            if (![db open]) {
                NSLog(@"Could not open db.");
                return;
            }
            FMResultSet *rs = [db executeQuery:selectLuckExist];
            if ([rs next]) {
                [db close];
                return ;
            }
            
            for (int i = 0; i<nameArray.count; i++) {
                BOOL sql = [db executeUpdate:@"insert into MONEYLUCK (constellation,content,start_date,week_sequence) values (?,?,?,?)",nameArray[i],contentArray[i],startDate,week];
                if (!sql) {
                    NSLog(@"ERROR: %d - %@", db.lastErrorCode, db.lastErrorMessage);
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:LuckChanged  object:nil];
            
          [db close];
            
        } failure:^(NSError * failure){
            NSLog(@"%@",failure);
        }];
    }
}

-(void)insertDefaultCategoryToDB:(FMDatabase *)database
{
    if ([CommonUtility isSystemLangChinese]) {
        
        
        BOOL sql =   [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('正餐',0,82,199,191)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('零食',0,255,224,102)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('交通',0,112,193,179)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('娱乐',0,213,120,32)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('服饰',0,177,212,50)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('旅游',0,245,71,143)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('医疗',0,220,73,97)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('日用品',0,244,91,105)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('水电煤',0,170,132,176)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('话费',0,2,128,144)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('住房',0,254,147,140)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('孩子',0,199,73,5)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('培训',0,234,210,172)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('宠物',0,156,175,183)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('数码',0,254,95,85)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('书籍',0,240,182,127)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('礼品',0,141,153,174)"];
        ///////////////////////////////////////////
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('工资',1,199,239,207)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('奖金',1,232,63,11)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('兼职',1,255,191,0)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('外快',1,50,147,111)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('红包',1,255,202,212)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('理财收益',1,216,75,230)"];
        if (!sql) {
            NSLog(@"CATEGORY ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }else
    {
        BOOL sql =  [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Dining',0,82,199,191)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Grocery',0,214,209,177)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Car',0,255,224,102)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Transport',0,112,193,179)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Amusement',0,213,120,32)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Clothing',0,177,212,50)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Travel',0,245,71,143)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Healthcare',0,220,73,97)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Utilities',0,244,91,105)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Home',0,170,132,176)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Telephone',0,2,128,144)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Rent',0,254,147,140)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Kids',0,199,73,5)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Education',0,234,210,172)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Pets',0,156,175,183)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Hobbies',0,254,95,85)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Reading',0,240,182,127)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Gifts',0,141,153,174)"];
        
        
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Salary',1,199,239,207)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Bonus',1,232,63,11)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Business',1,255,191,0)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Gift',1,255,202,212)"];
        
        [database executeUpdate:@"insert into CATEGORYINFO (category_name,category_type,color_R,color_G,color_B) values ('Extra',1,216,75,230)"];
        
        if (!sql) {
            NSLog(@"CATEGORY ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
        }
    }
    
}

-(void)insertDefaultColorToDB:(FMDatabase *)database
{
    BOOL sql =      [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (255,185,151,0)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (173,82,60,0)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (120,17,87,0)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (70,32,76,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (255,224,102,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (112,193,179,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (213,120,32,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (177,212,50,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (245,71,143,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (220,73,97,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (244,91,105,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (82,199,191,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (2,128,144,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (254,147,140,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (199,73,5,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (234,210,172,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (156,175,183,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (254,95,85,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (240,182,127,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (141,153,174,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (214,209,177,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (199,239,207,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (232,63,11,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (255,191,0,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (50,147,111,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (255,202,212,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (216,75,230,1)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (239,58,59,0)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (157,129,137,0)"];
    
    [database executeUpdate:@"insert into COLORINFO (color_R,color_G,color_B, used_count)values (116,84,106,0)"];
    
    
    
    if (!sql) {
        NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
    }
    
}


-(void)insertDefaultGOALSToDB:(FMDatabase *)database
{
    BOOL sql =  [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'沟通',0,0,10,0,0,0)"];
    
    [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(0,'培训',0,0,5,0,0,0)"];
    
    [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'阅读',1,20,0,0,0,0)"];
    
    [database executeUpdate:@"INSERT INTO GOALS(TYPE,theme,byTime,target_time,target_count,done_time,done_count,is_completed) VALUES(1,'跑步',1,50,0,0,0,0)"];
    
    if (!sql) {
        NSLog(@"COLOR ERROR: %d - %@", database.lastErrorCode, database.lastErrorMessage);
    }
    
}

-(void)configShare
{
    NSLog(@"configShare");

    
//    [MobClick startWithAppkey:@"573ab031e0f55ac2c900313c" reportPolicy:REALTIME   channelId:nil];
//    [MobClick setAppVersion:VERSIONNUMBER];
//    
//    
//    [OpenShare connectQQWithAppId:@"1105385156"];
//    [OpenShare connectWeiboWithAppKey:@"3086417886"];
//    [OpenShare connectWeixinWithAppId:@"wx0932d291dbf97131"];
}



@end
