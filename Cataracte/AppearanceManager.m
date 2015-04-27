//
//  AppearanceManager.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "AppearanceManager.h"
#import "UserInfoManager.h"
#import "UIColor+Utilities.h"

@interface AppearanceManager()

@property (assign, nonatomic) AppearanceManagerColorscheme colorscheme;

@end

@implementation AppearanceManager

#pragma mark -  Lifecycle

-(id)init
{
    return nil;
}

-(id)initPrivate
{
    if (self = [super init]) {
        NSNumber *colorscheme = [UserInfoManager sharedInstance].uCurrentColorscheme;
        
        if (colorscheme) {
            self.colorscheme = colorscheme.unsignedIntegerValue;
        }
        else {
            // default
            self.colorscheme = AppearanceManagerColorschemeRed;
        }
    }
    
    return self;
}

+(AppearanceManager *)sharedInstance
{
    static AppearanceManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[AppearanceManager alloc] initPrivate];
    });
    
    return instance;
}

-(void)setColorscheme:(AppearanceManagerColorscheme)colorscheme
{
    _colorscheme = colorscheme;
    
    [[UIButton appearance] setTintColor:[[self class] textMainColorForScheme:colorscheme]];
}

#pragma mark -  Public

+(AppearanceManagerColorscheme)colorscheme
{
    return [self sharedInstance].colorscheme;
}

+(void)changeColorschemeTo:(AppearanceManagerColorscheme)newColorscheme
{
    [self sharedInstance].colorscheme = newColorscheme;
    
    [UserInfoManager sharedInstance].uCurrentColorscheme = @(newColorscheme);
}

+(UIColor *)tintColor
{
    return [self textMainColorForScheme:self.colorscheme];
}

+(UIFont *)fontNormalWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+(UIFont *)fontBoldWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

+(UIColor *)textMainColorForScheme:(AppearanceManagerColorscheme)scheme
{
    if (scheme == AppearanceManagerColorschemeRed) {
        return [UIColor uColorOpaqueWithRed:229 green:84 blue:81];
    }
    else if (scheme == AppearanceManagerColorschemeIce) {
        return [UIColor uColorOpaqueWithRed:38 green:133 blue:172];
    }
    else if (scheme == AppearanceManagerColorschemeOrange) {
        return [UIColor uColorOpaqueWithRed:245 green:156 blue:37];
    }
    else if (scheme == AppearanceManagerColorschemePurple) {
        return [UIColor uColorOpaqueWithRed:82 green:58 blue:175];
    }
    
    return nil;
}

@end
