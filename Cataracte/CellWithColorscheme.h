//
//  CellWithColorscheme.h
//  Cataracte
//
//  Created by Adrien Long on 22/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppearanceManager.h"
#import "UITableViewCell+Utilities.h"

@protocol CellWithColorschemeDelegate;

@interface CellWithColorscheme : UITableViewCell

@property (weak, nonatomic) id <CellWithColorschemeDelegate> delegate;

- (void)redraw;
+ (CGFloat)height;

@end

@protocol CellWithColorschemeDelegate <NSObject>
- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme;
@end

