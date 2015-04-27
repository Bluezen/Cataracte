//
//  QBitTorrentsListCell.h
//  Cataracte
//
//  Created by Adrien Long on 24/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Utilities.h"

@class QBitTorrent;

@interface QBitTorrentsListCell : UITableViewCell

@property(nonatomic, strong) QBitTorrent *torrent;

+(CGFloat)height;

@end
