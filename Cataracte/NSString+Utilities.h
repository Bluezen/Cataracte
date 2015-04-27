//
//  NSString+Utilities.h
//  Cataracte
//
//  Created by Adrien Long on 21/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utilities)

-(BOOL)isNilOrEmpty;

/// Returns YES if self strictly validates the regexpression, NO otherwise.
-(BOOL)validateRegExpression:(NSRegularExpression *)regexp;

@end
