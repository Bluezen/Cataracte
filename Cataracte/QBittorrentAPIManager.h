//
//  QbittorentAPIManager.h
//  Cataracte
//
//  Created by Adrien Long on 13/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Bolts/Bolts.h>

#import "QBitTorrent.h"
#import "QBitGlobalInfo.h"

@class QBittorrentAPIManagerConfig;

typedef void(^QBittorrentAPIManagerConfigBlock)(QBittorrentAPIManagerConfig *config);


// qBittorrent version 3.1.x API:  https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-Documentation#authorization
// qBittorent version 3.2.x draft changelog API: https://gist.github.com/pmzqla/7e5733dbecfc50ee4ecd
@interface QBittorrentAPIManager : NSObject

@property(nonatomic, readonly) QBittorrentAPIManagerConfig *currentConfig;

+(instancetype)sharedInstance;

/// This method could be seen as a flagrant abuse of the singleton pattern. One could see currentConfig as a scoped state that implies QBittorrentAPIManager to be passed with dependancy injection instead of being used as a singleton... I agree and this might change in the futur.
+(void)resetSharedInstance;
-(instancetype)switchToConfig:(QBittorrentAPIManagerConfig *)config;
-(instancetype)switchWithConfigBlock:(QBittorrentAPIManagerConfigBlock)block;

/// Task result is the statusCode of the response.
-(BFTask *)shutdownQbittorent;

/// Task result is an array of QBitTorrent
-(BFTask *)getTorrentList;
/// Task result is the torrent with generic info set.
-(BFTask *)getTorrentGenericInfo:(QBitTorrent *)torrent;
/// Task result is the torrent with trackers info set.
-(BFTask *)getTorrentTrackers:(QBitTorrent *)torrent;
/// Task result is the torrent with contents info set.
-(BFTask *)getTorrentContents:(QBitTorrent *)torrent;
/// Task result is a QBitGlobalInfo
-(BFTask *)getGlobalTransferInfo;

/// links is an array of url string. http://, https://, magnet: and bc://bt/ links are supported. Task returns status code (always 200, no matter if successful or not).
-(BFTask *)downloadTorrentsFromLinks:(NSArray *)links;
/// Task returns status code (always 200, no matter if successful or not).
-(BFTask *)pauseTorrent:(QBitTorrent *)torrent;

-(BFTask *)pauseAllTorrents;

-(BFTask *)resumeTorrent:(QBitTorrent *)torrent;

-(BFTask *)resumeAllTorrents;

-(BFTask *)deleteTorrents:(NSArray *)torrents;

-(BFTask *)deleteDownloadedDataAndTorrents:(NSArray *)torrents;

-(BFTask *)recheckTorrent:(QBitTorrent *)torrent;

-(BFTask *)increasePriorityOfTorrents:(NSArray *)torrents;

-(BFTask *)decreasePriorityOfTorrents:(NSArray *)torrents;

-(BFTask *)setMaximalPriorityToTorrents:(NSArray *)torrents;

-(BFTask *)setMinimalPriorityToTorrents:(NSArray *)torrents;

-(BFTask *)setContentPriority:(QBitTorrentContentPriority)priority ofContentWithId:(NSInteger)idNumber fromTorrent:(QBitTorrent *)torrent;

/// Deprecated in API v2; use getGlobalTransferInfo instead.
-(BFTask *)getGlobalDownloadLimit;

-(BFTask *)setGlobalDownloadLimit:(NSInteger)bytes;

/// Deprecated in API v2; use getGlobalTransferInfo instead.
-(BFTask *)getGlobalUploadLimit;

-(BFTask *)setGlobalUploadLimit:(NSInteger)bytes;

@end



typedef NS_ENUM(NSUInteger, QBittorrentVersion) {
    QBittorrentVersion_2_X = 0,
    QBittorrentVersion_3_1_X,
    QBittorrentVersion_3_2_X
};

NSString *NSStringFromQBittorrentVersion(QBittorrentVersion version);

//NS_ASSUME_NONNULL_BEGIN // messes with autocompletion of functions using typedef blocks parameters, like managerWithConfigBlock:
@interface QBittorrentAPIManagerConfig : NSObject<NSCopying>

/// Mandatory.
@property(nonatomic, strong) NSString *m_host;

/// Optional. Default is 8080.
@property(nonatomic, strong) NSNumber *m_port;

/// Optional. If not set, we try to fetch it from keychain.
@property(nonatomic, strong) NSString *m_username;

/// Optional. If not set, we try to fetch it from keychain.
@property(nonatomic, strong) NSString *m_password;

/// Optional. Default value QBittorrentVersion_3_1_X
@property(nonatomic, assign) QBittorrentVersion m_version;

@end
