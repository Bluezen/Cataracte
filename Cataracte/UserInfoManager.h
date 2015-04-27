//
//  UserInfoManager.h
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoManager : NSObject

@property(nonatomic, strong) NSNumber *uCurrentColorscheme;


@property(nonatomic, strong) NSString *uQBittorrentHost;
@property(nonatomic, strong) NSNumber *uQBittorrentPort;
@property(nonatomic, strong) NSString *uQBittorrentUsername;

@property(nonatomic, strong) NSNumber *uQBittorrentVersion;

+(instancetype)sharedInstance;

-(void)createDefaultValuesIfNeeded;

@end
