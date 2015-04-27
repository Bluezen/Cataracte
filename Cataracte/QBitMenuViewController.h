//
//  QBittorrentMenuViewController.h
//  Cataracte
//
//  Created by Adrien Long on 21/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StaticTableViewController.h"

#import "QBitTorrentsListViewController.h"

@interface QBitMenuViewController : StaticTableViewController <QBitTorrentsListViewControllerDelegate>

-(void)addTorrentWithMagnet:(NSString *)magnetLink;

@end
