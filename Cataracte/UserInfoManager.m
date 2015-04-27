//
//  UserInfoManager.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "UserInfoManager.h"

@implementation UserInfoManager


#pragma mark -  Lifecycle

-(id)init
{
    return nil;
}

-(id)initPrivate
{
    if (self = [super init]) {
        
    }
    
    return self;
}

+(instancetype)sharedInstance
{
    static UserInfoManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[UserInfoManager alloc] initPrivate];
    });
    
    return instance;
}

#pragma mark -  Methods

-(void)createDefaultValuesIfNeeded
{
    if (! self.uCurrentColorscheme) {
        self.uCurrentColorscheme = @(0);
    }
    if (! self.uQBittorrentPort) {
        self.uQBittorrentPort = @(8080);
    }
    if (! self.uQBittorrentHost) {
        self.uQBittorrentHost = @"192.168.1.20";
    }
    if (! self.uQBittorrentVersion) {
        self.uQBittorrentVersion = @(1);
    }
}

#pragma mark - Properties

/**
 * theProperty - property without "u" prefix
 *
 * Example:
 * @property NSString *uMyString;
 *
 * GENERATE_OBJECT(MyString, kMyStringKey, NSString *)
 */
#define GENERATE_OBJECT(theProperty, theKey, theType) \
- (void)setU##theProperty:(theType)object \
{ \
@synchronized(self) { \
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; \
[defaults setObject:object forKey:theKey]; \
[defaults synchronize]; \
} \
} \
\
- (theType)u##theProperty \
{ \
@synchronized(self) { \
return [[NSUserDefaults standardUserDefaults] objectForKey:theKey]; \
} \
}


GENERATE_OBJECT(CurrentColorscheme, @"current-colorscheme", NSNumber *)
GENERATE_OBJECT(QBittorrentHost, @"qBittorent-host", NSString *)
GENERATE_OBJECT(QBittorrentPort, @"qBittorent-port", NSNumber *)
GENERATE_OBJECT(QBittorrentUsername, @"qBittorent-username", NSString *)
GENERATE_OBJECT(QBittorrentVersion, @"qBittorent-version", NSNumber *)

@end
