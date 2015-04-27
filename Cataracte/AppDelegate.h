//
//  AppDelegate.h
//  Cataracte
//
//  Created by Adrien Long on 06/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AppDelegateTabIndex) {
    AppDelegateTabIndexTops = 0,
    AppDelegateTabIndexSearch,
    AppDelegateTabIndexBookmarks,
    AppDelegateTabIndexQBittorrent,
    AppDelegateTabIndexSettings,
};

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex;
- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
                         withBlock:(void (^)(UINavigationController *topNavigation))block;

@end

