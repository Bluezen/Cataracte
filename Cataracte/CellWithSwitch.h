//
//  CellWithSwitch.h
//  Cataracte
//
//  Created by Adrien Long on 22/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Utilities.h"

@protocol CellWithSwitchDelegate;

@interface CellWithSwitch : UITableViewCell

@property(nonatomic, weak) id <CellWithSwitchDelegate> delegate;

@property(nonatomic, strong) NSString *title;
@property(nonatomic, assign) BOOL on;

@end

@protocol CellWithSwitchDelegate <NSObject>
-(void)cellWithSwitchStateChanged:(CellWithSwitch *)cell;
@end
