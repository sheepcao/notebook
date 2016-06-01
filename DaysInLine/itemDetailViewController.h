//
//  itemDetailViewController.h
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "baseViewController.h"

@interface itemDetailViewController : baseViewController

@property (nonatomic,strong) NSNumber *currentItemID;
@property (nonatomic,strong) NSString *money;
@property int itemType;
@property (nonatomic,strong) NSString *category;
@property (nonatomic,strong) NSString *itemDescription;
@property (nonatomic,strong) NSString *itemStartTime;
@property (nonatomic,strong) NSString *itemEndTime;
@property (nonatomic,strong) NSString *targetDate;
@property (nonatomic,strong) NSString *soundName;
@property (nonatomic,strong) NSString *photoNames;


@property BOOL isEditing;
@end
