//
//  UIAlertController+Cataracte.h
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (Cataracte)

+(instancetype)alertStrikeAPINotOnlineWithOKAction:(void (^)(UIAlertAction *action))handler;

@end
