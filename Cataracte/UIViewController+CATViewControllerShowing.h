//
//  UIViewController+CATViewControllerShowing.h
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

/*
 Abstract:
 
 A category that gives information about how view controllers will be shown, for determining disclosure indicator visibility and row deselection.
 */

#import <UIKit/UIKit.h>

@interface UIViewController (CATViewControllerShowing)

/// Returns whether calling showViewController:sender: would cause a navigation "push" to occur.
- (BOOL)cat_willShowingViewControllerPushWithSender:(id)sender;

/// Returns whether calling showDetailViewController:sender: would cause a navigation "push" to occur.
- (BOOL)cat_willShowingDetailViewControllerPushWithSender:(id)sender;

@end
