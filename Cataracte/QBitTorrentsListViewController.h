//
//  QBitTorrentsList.h
//  Cataracte
//
//  Created by Adrien Long on 24/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol QBitTorrentsListViewControllerDelegate;


@interface QBitTorrentsListViewController : UITableViewController

@property(nonatomic, strong) NSArray *torrents;

@property(nonatomic, weak) id<QBitTorrentsListViewControllerDelegate> delegate;

@end


@protocol QBitTorrentsListViewControllerDelegate <NSObject>

-(void)qBitTorrentsListViewControllerRefreshButtonPushed:(QBitTorrentsListViewController *)viewController;

@end