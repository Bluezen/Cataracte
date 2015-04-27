//
//  UINavigationController+Utilities.h
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Utilities)

/// Returns a new navigation controller set with specified root view controller and current tintColor set for its navigation bar
+(instancetype)navControllerWithRoot:(UIViewController *)rootViewController;

@end
