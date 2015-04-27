//
//  UITableViewCell+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UITableViewCell+Utilities.h"

@implementation UITableViewCell (Utilities)

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

@end
