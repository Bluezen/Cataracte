//
//  TorrentsListCell.h
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Utilities.h"

@class StrikeTorrent;

@interface StrikeTorrentsListCell : UITableViewCell

@property(nonatomic, strong) StrikeTorrent *torrent;

+(CGFloat)height;

@end
