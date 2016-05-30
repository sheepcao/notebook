//
//  itemDetailTableViewCell.m
//  simpleFinance
//
//  Created by Eric Cao on 4/23/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "itemDetailTableViewCell.h"
#import "global.h"

@implementation itemDetailTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        self.leftText = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, SCREEN_WIDTH*2/5+10, 35)];
        
        self.rightText = [[UIButton alloc] initWithFrame:CGRectMake(self.leftText.frame.origin.x + self.leftText.frame.size.width +10, 28, SCREEN_WIDTH*3/5 -10 - 20-20 -10, 30)];
        self.rightText.layer.borderWidth = 0.75f;
        self.rightText.layer.borderColor = [UIColor grayColor].CGColor;
        self.rightText.layer.cornerRadius = 5;
        [self addSubview:self.leftText ];
        [self addSubview:self.rightText ];
        
        self.leftText.font = [UIFont fontWithName:@"HelveticaNeue" size:14.5f];
        self.leftText.textAlignment = NSTextAlignmentLeft;
        self.rightText.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        self.rightText.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.rightText.titleLabel.numberOfLines = 2;
        self.rightText.titleLabel.minimumScaleFactor = 0.8;
        
    }
    return self;
}

-(void)addExpend
{
    UIImageView *expendImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.rightText.frame.size.width - 30, 6, 20, 20)];
    NSString *showModel =  [[NSUserDefaults standardUserDefaults] objectForKey:SHOWMODEL];
    if (!showModel) {
        [expendImage setImage:[UIImage imageNamed:@"expend0"]];
    }else if ([showModel isEqualToString:@"上午"]) {
        [expendImage setImage:[UIImage imageNamed:@"expend0"]];
    }else if([showModel isEqualToString:@"夜间"]) {
        [expendImage setImage:[UIImage imageNamed:@"expend"]];
    }
    expendImage.tag = 10;
    
    if (![self.rightText viewWithTag:10]) {
        [self.rightText addSubview:expendImage];
    }
    
}



- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
