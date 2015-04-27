//
//  AppDelegate+Cataracte.h
//  Cataracte
//
//  Created by Adrien Long on 25/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (Cataracte)

- (UIViewController *)visibleViewController;

-(void)switchToDownloadTabAndShowTorrentsListViewControllerWithMagnetLink:(NSString *)magnetLink;

@end
