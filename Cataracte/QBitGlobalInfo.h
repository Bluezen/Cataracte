//
//  QBitGlobal.h
//  Cataracte
//
//  Created by Adrien Long on 16/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping/EasyMapping.h>

typedef enum {
    QBitGlobalInfoConnectionStatusConnected,
    QBitGlobalInfoConnectionStatusFirewalled,
    QBitGlobalInfoConnectionStatusDisconnected
} QBitGlobalInfoConnectionStatus;

@interface QBitGlobalInfo : NSObject<EKMappingProtocol>

#pragma mark - QBittorent API - Global Transfert Info


/// API VERSION 1 ONLY: (translated string) contains current global downalod speed and global amount of data downaloded during this session
@property(nonatomic, copy) NSString *   dlInfo;
/// API VERSION 1 ONLY: (translated string) contains current global upload speed and global amount of data uploaded during this session
@property(nonatomic, copy) NSString *   upInfo;


/// API VERSION 2 ONLY: Global download rate (bytes/s)
@property(nonatomic, assign) NSInteger  dlSpeed;
/// API VERSION 2 ONLY: Data downloaded this session (bytes)
@property(nonatomic, assign) NSInteger  dlData;


/// API VERSION 2 ONLY: Global upload rate (bytes/s)
@property(nonatomic, assign) NSInteger  upSpeed;
/// API VERSION 2 ONLY: Data uploaded this session (bytes)
@property(nonatomic, assign) NSInteger  upData;

/// API VERSION 2 ONLY: Download rate limit (bytes/s)
@property(nonatomic, assign) NSInteger  dlRateLimit;
/// API VERSION 2 ONLY: Upload rate limit (bytes/s)
@property(nonatomic, assign) NSInteger  upRateLimit;

/// API VERSION 2 ONLY: DHT nodes connected to
@property(nonatomic, assign) NSInteger  dhtNodes;

/// API VERSION 2 ONLY: Connection status.
@property(nonatomic, assign) QBitGlobalInfoConnectionStatus status;

@end
