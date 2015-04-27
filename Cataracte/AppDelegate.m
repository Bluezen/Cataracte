//
//  AppDelegate.m
//  Cataracte
//
//  Created by Adrien Long on 06/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "AppDelegate.h"
#import "StrikeTorrentsListViewController.h"

#import "UserInfoManager.h"
#import "AppearanceManager.h"

#import "StrikeTopsViewController.h"
#import "StrikeSearchesViewController.h"
#import "SettingsViewController.h"
#import "StrikeBookmarksViewController.h"
#import "UIViewController+CATViewControllerShowing.h"
#import "UINavigationController+Utilities.h"
#import "DatabaseManager.h"
#import "QBitMenuViewController.h"

#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>

@interface AppDelegate () <UISplitViewControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[UserInfoManager sharedInstance] createDefaultValuesIfNeeded];
    [[DatabaseManager sharedInstance] configureCreationAndMigration];
    
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
    [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
    
    [self recreateControllersAndShow:AppDelegateTabIndexQBittorrent];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Public

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
{
    [self recreateControllersAndShow:tabIndex withBlock:nil];
}

- (void)recreateControllersAndShow:(AppDelegateTabIndex)tabIndex
                         withBlock:(void (^)(UINavigationController *topNavigation))block;
{
    UINavigationController *tops = [UINavigationController navControllerWithRoot:[StrikeTopsViewController new]];
    UINavigationController *search = [UINavigationController navControllerWithRoot:[StrikeSearchesViewController new]];
    UINavigationController *bookmarks = [UINavigationController navControllerWithRoot:[StrikeBookmarksViewController new]];
    UINavigationController *qbittorrent = [UINavigationController navControllerWithRoot:[QBitMenuViewController new]];
    UINavigationController *settings = [UINavigationController navControllerWithRoot:[SettingsViewController new]];
    
    UITabBarController *master = [UITabBarController new];
    master.viewControllers = @[tops, search, bookmarks, qbittorrent, settings];
    
    master.tabBar.tintColor = [AppearanceManager tintColor];
    
    tops.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemTopRated
                                                                 tag:AppDelegateTabIndexTops];
    
    search.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch
                                                                   tag:AppDelegateTabIndexSearch];
    
    bookmarks.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemBookmarks
                                                                   tag:AppDelegateTabIndexBookmarks];
    
    qbittorrent.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemDownloads
                                                                      tag:AppDelegateTabIndexQBittorrent];
    
    settings.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore
                                                                     tag:AppDelegateTabIndexSettings];
    
    master.selectedIndex = tabIndex;
    
    
    UIViewController *detail = [StrikeTorrentsListViewController new];
    UINavigationController *detailNav = [UINavigationController navControllerWithRoot:detail];
    
    UISplitViewController *controller = [UISplitViewController new];
    controller.viewControllers = @[master, detailNav];
    controller.delegate = self;
    controller.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;

    detail.navigationItem.leftBarButtonItem = controller.displayModeButtonItem;
    
    self.window.rootViewController = controller;
    
    if (block) {
        block((UINavigationController *) master.selectedViewController);
    }
}

#pragma mark - Split view

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController {
    
    if ([secondaryViewController isKindOfClass:[UINavigationController class]] && [[(UINavigationController *)secondaryViewController topViewController] isKindOfClass:[StrikeTorrentsListViewController class]] && ([(StrikeTorrentsListViewController *)[(UINavigationController *)secondaryViewController topViewController] torrents] == nil)) {
        // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
        return YES;
    } else {
        return NO;
    }
}

//-(UIViewController *)splitViewController:(UISplitViewController *)splitViewController separateSecondaryViewControllerFromPrimaryViewController:(UIViewController *)primaryViewController
//{
//    if ([primaryViewController isKindOfClass:[UINavigationController class]]) {
//        NSArray *viewControllers = [(UINavigationController *)primaryViewController viewControllers];
//        for (UIViewController *controller in viewControllers) {
//            if ([controller aapl_containedPhoto]) {
//                // Do the standard behavior if we have a photo.
//                return nil;
//            }
//        }
//    }
//    // If there's no content on the navigation stack, make an empty view controller for the detail side.
//    return [[UIViewController alloc] init];
//}

-(BOOL)splitViewController:(UISplitViewController *)splitViewController showViewController:(UIViewController *)vc sender:(id)sender
{
    return NO;
}

-(BOOL)splitViewController:(UISplitViewController *)splitViewController showDetailViewController:(UIViewController *)vc sender:(id)sender
{
    if ([sender isKindOfClass:[UIViewController class]]) {
        UIViewController *vcSender = sender;
        BOOL pushes = [vcSender cat_willShowingDetailViewControllerPushWithSender:sender];
        if (pushes) {
            if ([vc isKindOfClass:[UINavigationController class]]) {
                UIViewController *controllerToPush = ((UINavigationController*)vc).viewControllers.lastObject;
                [vcSender.navigationController pushViewController:controllerToPush animated:YES];
            } else {
                [vcSender.navigationController pushViewController:vc animated:YES];
            }
            return YES;
        }
    }
    
    return NO;
}

@end
