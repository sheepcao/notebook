//
//  highLightButton.m
//  DaysInLine
//
//  Created by Eric Cao on 6/2/16.
//  Copyright © 2016 sheepcao. All rights reserved.
//

#import "highLightButton.h"
#import "global.h"

@implementation highLightButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.layer.borderColor =  [UIColor colorWithRed:223/255.0f green:162/255.0f blue:57/255.0f alpha:1.0f].CGColor;
    }else
    {
        self.layer.borderColor =  normalColor.CGColor;

    }
}

@end
