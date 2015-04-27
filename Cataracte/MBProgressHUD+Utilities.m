//
//  MBProgressHUD+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 27/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "MBProgressHUD+Utilities.h"

@implementation MBProgressHUD (Utilities)

+(void)showForOneSecondHUDAddedTo:(UIView *)view withText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.margin = 10.f;
    hud.labelText = text;
    [hud hide:YES afterDelay:1.0];
}

@end
