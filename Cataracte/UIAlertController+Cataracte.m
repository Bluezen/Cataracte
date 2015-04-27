//
//  UIAlertController+Cataracte.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UIAlertController+Cataracte.h"
#import "AppearanceManager.h"

@implementation UIAlertController (Cataracte)

+(instancetype)alertStrikeAPINotOnlineWithOKAction:(void (^)(UIAlertAction *action))handler
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Network error", @"") message:NSLocalizedString(@"Strike API can't be reached. Please try again later or check your connection.", @"") preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK action") style:UIAlertActionStyleDefault handler:handler];
    
    [controller addAction:okAction];
    
    controller.view.tintColor = [AppearanceManager tintColor];
    
    return controller;
}

@end
