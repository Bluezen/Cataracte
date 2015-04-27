//
//  UINavigationController+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UINavigationController+Utilities.h"
#import "AppearanceManager.h"

@implementation UINavigationController (Utilities)

+(instancetype)navControllerWithRoot:(UIViewController *)rootViewController
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    nav.navigationBar.tintColor = [AppearanceManager tintColor];
    return nav;
}

@end
