//
//  TorrentDetailsViewController.h
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StrikeTorrent;

@interface StrikeTorrentDetailsViewController : UIViewController

@property(nonatomic, strong) StrikeTorrent *torrent;

@end
