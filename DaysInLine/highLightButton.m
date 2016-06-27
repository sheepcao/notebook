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

- (void)drawRect:(CGRect)rect {
  UIColor * backColor = [UIColor colorWithRed:253/255.0f green:142/255.0f blue:28/255.0f alpha:1.0f];

CAGradientLayer *gradientLayer = [CAGradientLayer layer];
gradientLayer.frame = CGRectMake(0, 0, self.frame.size.width/2, self.frame.size.height);
gradientLayer.colors = [NSArray arrayWithObjects:(id)[backColor colorWithAlphaComponent:0.05].CGColor, (id)[backColor colorWithAlphaComponent:0.25].CGColor,nil];

gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
gradientLayer.endPoint = CGPointMake(1.0f, 0.0f);
self.layer.mask = gradientLayer;
[self.layer insertSublayer:gradientLayer atIndex:0];

CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
gradientLayer1.frame = CGRectMake(self.frame.size.width/2,0, self.frame.size.width/2, self.frame.size.height);
gradientLayer1.colors = [NSArray arrayWithObjects:(id)[backColor colorWithAlphaComponent:0.05].CGColor, (id)[backColor colorWithAlphaComponent:0.25].CGColor,nil];

gradientLayer1.startPoint = CGPointMake(1.0f, 0.0f);
gradientLayer1.endPoint = CGPointMake(0.0f, 0.0f);
self.layer.mask = gradientLayer1;
[self.layer insertSublayer:gradientLayer1 atIndex:0];
}
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
