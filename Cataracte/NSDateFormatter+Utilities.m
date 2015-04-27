//
//  NSDateFormatter+Utilities.m
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "NSDateFormatter+Utilities.h"

NSString * const CATThreadDateFormatterKey = @"CATThreadDateFormatter";

@implementation NSDateFormatter (Utilities)

+(NSDateFormatter *)cat_formatterForCurrentThread
{
    NSMutableDictionary *dictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = [dictionary objectForKey:CATThreadDateFormatterKey];
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.dateFormat = StrikeDatetimeFormat;
        dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dictionary setObject:dateFormatter forKey:CATThreadDateFormatterKey];
    }
    return dateFormatter;
}

@end
