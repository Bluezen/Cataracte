//
//  NSString+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 21/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "NSString+Utilities.h"

@implementation NSString (Utilities)

-(BOOL)isNilOrEmpty
{
    return [self length] == 0;
}

-(BOOL)validateRegExpression:(NSRegularExpression *)regexp
{
    NSRange textRange = NSMakeRange(0, self.length);
    NSArray *matches = [regexp matchesInString:self options:0 range:textRange];
    
    NSRange resultRange = NSMakeRange(NSNotFound, 0);
    if (matches.count == 1)
    {
        NSTextCheckingResult *result = (NSTextCheckingResult *)matches[0];
        resultRange = result.range;
    }
    
    if (NSEqualRanges(textRange, resultRange))
        return YES;
    
    return NO;
}

@end
