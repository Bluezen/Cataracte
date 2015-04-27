//
//  AppearanceManager.h
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AppearanceManagerColorscheme) {
    AppearanceManagerColorschemeRed = 0,
    AppearanceManagerColorschemeIce,
    AppearanceManagerColorschemeOrange,
    AppearanceManagerColorschemePurple,
    __AppearanceManagerColorschemeCount,
};

@interface AppearanceManager : NSObject

+(AppearanceManagerColorscheme)colorscheme;
+(void)changeColorschemeTo:(AppearanceManagerColorscheme)newColorscheme;

+(UIColor *)tintColor;

+(UIFont *)fontNormalWithSize:(CGFloat)size;
+(UIFont *)fontBoldWithSize:(CGFloat)size;

+(UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme;

@end
