//
//  UIViewController+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UIViewController+Utilities.h"

@implementation UIViewController (Utilities)

- (void)loadWhiteView
{
    CGRect frame = CGRectZero;
    frame.size = [[UIScreen mainScreen] applicationFrame].size;
    
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
}

@end
