//
//  UIViewController+CATViewControllerShowing.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UIViewController+CATViewControllerShowing.h"


@implementation UIViewController (CATViewControllerShowing)

- (BOOL)cat_willShowingViewControllerPushWithSender:(id)sender
{
    // Find and ask the right view controller about showing.
    UIViewController *target = [self targetViewControllerForAction:@selector(cat_willShowingViewControllerPushWithSender:) sender:sender];
    if (target) {
        return [target cat_willShowingViewControllerPushWithSender:sender];
    } else {
        // Or if we can't find one, we won't be pushing.
        return NO;
    }
}

- (BOOL)cat_willShowingDetailViewControllerPushWithSender:(id)sender
{
    // Find and ask the right view controller about showing detail.
    UIViewController *target = [self targetViewControllerForAction:@selector(cat_willShowingDetailViewControllerPushWithSender:) sender:sender];
    if (target) {
        return [target cat_willShowingDetailViewControllerPushWithSender:sender];
    } else {
        // Or if we can't find one, we won't be pushing.
        return NO;
    }
}

@end

@implementation UINavigationController (CATViewControllerShowing)

- (BOOL)cat_willShowingViewControllerPushWithSender:(id)sender
{
    // Navigation Controllers always push for showViewController:.
    return YES;
}

@end

@implementation UITabBarController (CATViewControllerShowing)

- (BOOL)cat_willShowingViewControllerPushWithSender:(id)sender
{
    if (self.splitViewController.collapsed) {
        // If we're collapsed, re-ask this question as showViewController: to our primary view controller.
        UIViewController *target = self.selectedViewController;
        return [target cat_willShowingViewControllerPushWithSender:sender];
    } else {
        // Otherwise, we don't push for showDetailViewController:.
        return NO;
    }
}

@end

@implementation UISplitViewController (CATViewControllerShowing)

- (BOOL)cat_willShowingViewControllerPushWithSender:(id)sender
{
    // Split View Controllers never push for showViewController:.
    return NO;
}

- (BOOL)cat_willShowingDetailViewControllerPushWithSender:(id)sender
{
    if (self.collapsed) {
        // If we're collapsed, re-ask this question as showViewController: to our primary view controller.
        UIViewController *target = [self.viewControllers lastObject];
        return [target cat_willShowingViewControllerPushWithSender:sender];
    } else {
        // Otherwise, we don't push for showDetailViewController:.
        return NO;
    }
}

@end
