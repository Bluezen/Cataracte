//
//  UIView+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UIView+Utilities.h"

@implementation UIView (Utilities)

#pragma mark -  Public

- (UILabel *)addLabelWithTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    return [self configureAndAddLabel:[UILabel new] withTextColor:textColor bgColor:bgColor];
}

#pragma mark -  Private

- (UILabel *)configureAndAddLabel:(UILabel *)label withTextColor:(UIColor *)textColor bgColor:(UIColor *)bgColor
{
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    [self addSubview:label];
    
    return label;
}

@end
