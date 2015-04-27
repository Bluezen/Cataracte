//
//  UIColor+Utilities.h
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Utilities)

+(UIColor *)uColorOpaqueWithWhite:(unsigned char)white;

+(UIColor *)uColorWithWhite:(unsigned char)white alpha:(CGFloat)alpha;

+(UIColor *)uColorOpaqueWithRed:(unsigned char)red
                          green:(unsigned char)green
                           blue:(unsigned char)blue;

+(UIColor *)uColorWithRed:(unsigned char)red
                    green:(unsigned char)green
                     blue:(unsigned char)blue
                    alpha:(CGFloat)alpha;


@end
