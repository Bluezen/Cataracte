//
//  AppDelegate+Cataracte.m
//  Cataracte
//
//  Created by Adrien Long on 25/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "AppDelegate+Cataracte.h"
#import "QBitMenuViewController.h"

@implementation AppDelegate (Cataracte)

#pragma mark -  Public

- (UIViewController *)visibleViewController
{
    UISplitViewController *splitView = (UISplitViewController *)self.window.rootViewController;
    
    UITabBarController *tabBar = splitView.viewControllers.firstObject;
    
    UINavigationController *navCon = (UINavigationController *)[tabBar selectedViewController];
    
    return [navCon topViewController];
}

-(void)switchToDownloadTabAndShowTorrentsListViewControllerWithMagnetLink:(NSString *)magnetLink
{
    UINavigationController *navCon = [self switchToIndexAndGetNavigation:AppDelegateTabIndexQBittorrent];
    
    if (navCon.viewControllers.count > 1) {
        // We are on iPhone/horizontally constricted env
        [navCon popToRootViewControllerAnimated:NO];
    }
    
    QBitMenuViewController *menuVC = navCon.viewControllers.firstObject;
    
    [menuVC addTorrentWithMagnet:magnetLink];
}

#pragma mark -  Private

- (UINavigationController *)switchToIndexAndGetNavigation:(AppDelegateTabIndex)index
{
    UISplitViewController *splitView = (UISplitViewController *)self.window.rootViewController;
    
    UITabBarController *tabBar = splitView.viewControllers.firstObject;
    
    tabBar.selectedIndex = index;
    
    return (UINavigationController *)[tabBar selectedViewController];
}

@end
