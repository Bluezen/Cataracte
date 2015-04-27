//
//  NSDateFormatter+Utilities.h
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const StrikeDatetimeFormat = @"MMM dd,yyyy";

/**
 Category on NSDateFormatter, that allows getting NSDateFormatter for current thread.
 
 Note. On iOS 7 and higher and Mac OS X 10.7 and higher NSDateFormatter is thread-safe, so it's safe to use date formatter across multiple threads.
 */
@interface NSDateFormatter (Utilities)

/**
 NSDateFormatter instance for current NSThread. It is lazily constructed, default date format set to Strike API datetime format.
 */
+ (NSDateFormatter *)cat_formatterForCurrentThread;

@end
