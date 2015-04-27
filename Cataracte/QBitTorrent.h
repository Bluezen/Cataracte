//
//  QBitTorrent.h
//  Cataracte
//
//  Created by Adrien Long on 15/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EasyMapping/EasyMapping.h>

typedef enum {
    /// some error occurred, applies to paused torrents
    QBitTorrentStateError,
    /// torrent is paused and has finished downloading
    QBitTorrentStatePausedUP,
    /// torrent is paused and has NOT finished downloading
    QBitTorrentStatePausedDL,
    /// queuing is enabled and torrent is queued for upload
    QBitTorrentStateQueuedUP,
    /// queuing is enabled and torrent is queued for download
    QBitTorrentStateQueuedDL,
    /// torrent is being seeded and data is being transfered
    QBitTorrentStateUploading,
    /// torrent is being seeded, but no connection were made
    QBitTorrentStateStalledUP,
    /// torrent has finished downloading and is being checked; this status also applies to preallocation (if enabled) and checking resume data on qBt startup
    QBitTorrentStateCheckingUP,
    /// same as checkingUP, but torrent has NOT finished downloading
    QBitTorrentStateCheckingDL,
    /// torrent is being downloaded and data is being transfered
    QBitTorrentStateDownloading,
    /// torrent is being downloaded, but no connection were made
    QBitTorrentStateStalledDL
} QBitTorrentState;

typedef enum {
    QBitTorrentContentPriorityDoNotDownload = 0,
    QBitTorrentContentPriorityNormal = 1,
    QBitTorrentContentPriorityHigh = 2,
    QBitTorrentContentPriorityMaximal = 7
} QBitTorrentContentPriority;

@interface QBitTorrent : NSObject<EKMappingProtocol>

#pragma mark - QBittorent API - Torrent List Infos

@property(nonatomic, copy) NSString *   hashId;
@property(nonatomic, copy) NSString *   name;
/// Size has a suffix appended in the language of qBittorent. Can be 'Unknown'.
@property(nonatomic, copy) NSString *   size;
/// Float number for download completion percentage, where 1 == 100%, 0 == 0%, and, 0.58 == 58%
@property(nonatomic, assign) float      progress;
/// Torrent download speed with suffix/s. Can be 'Unknown'
@property(nonatomic, copy) NSString *   dlSpeed;
/// Torrent upload speed with suffix/s. Can be 'Unknown'
@property(nonatomic, copy) NSString *   upSpeed;
/// Torrent number in priority queue; contains * if queuing is disabled or torrent is in seed mode.
@property(nonatomic, copy) NSString *   priority;
/// num_seeds  - number of peers
@property(nonatomic, assign) NSInteger nbSeeds;
/// num_leechs - number of lecchers
@property(nonatomic, assign) NSInteger nbLeechs;
///  Uploaded/Downloaded ratio, rounded to first digit after comma; contains ∞ if ratio > 100
@property(nonatomic, copy) NSString *   ratio;
/**
 eta - contains ∞ ('\u221e') if torrent is seeding only or eta >= 8640000 seconds; possible values:
 
 0 - zero
 < 1m - less than a minute
 MMm - MM minutes
 HHh MMm - HH hours and MM minutes
 DDd HHh - DD days and HH hours
 
 DD/HH/MM values can be truncated if first digit is zero
 */
@property(nonatomic, copy) NSString *   eta;

@property(nonatomic, assign) QBitTorrentState  state;

#pragma mark - QBittorent API - Torrent Generic Properties

/// path - path where torrent contents are saved, separated by slashes
@property(nonatomic, copy) NSString *   path;

/// creation_date - (translated string) date when torrent was added
@property(nonatomic, copy) NSString *   creationDate;
/// piece_size - (translated string) torrent piece size
@property(nonatomic, copy) NSString *   pieceSize;
/// comment - torrent comment
@property(nonatomic, copy) NSString *   comment;
/// total_wasted - (translated string) amount of data 'wasted'
@property(nonatomic, copy) NSString *   totalWasted;
/// total_uploaded - (translated string) amounts of data uploaded , value in parentheses count current session data only
@property(nonatomic, copy) NSString *   upTotal;
/// total_downloaded - (translated string) amounts of data downloaded, value in parentheses count current session data only
@property(nonatomic, copy) NSString *   dlTotal;
/// up_limit - (translated string) upload speed limits for current torrent
@property(nonatomic, copy) NSString *   upSpeedLimit;
/// dl_limit - (translated string) download speed limits for current torrent
@property(nonatomic, copy) NSString *   dlSpeedLimit;
/// time_elapsed - (translated string) total time active; value in parentheses represents current seeding time
@property(nonatomic, copy) NSString *   timeElapsed;
/// nb_connections - (translated string) number of connections, value in parentheses represents maximum number of connections per torrent set in preferences
@property(nonatomic, copy) NSString *   nbConnections;
/// share_ratio - (translated string) UL/DL ratio; contains ∞ for ratios > 100
@property(nonatomic, copy) NSString *   shareRatio;

#pragma mark - QBittorent API - Trackers

@property(nonatomic, strong) NSArray *  trackers;

#pragma mark - QBittorent API - Contents

@property(nonatomic, strong) NSArray *  contents;

@end


@interface QBitTorrentTracker : NSObject<EKMappingProtocol>

/// Tracker url
@property (nonatomic, strong) NSURL *   url;
/// status - (translated string) tracker status
@property (nonatomic, copy) NSString *  status;
/// num_peers - number of peers for current torrent eported by tracker
@property(nonatomic, assign) NSInteger  nbPeers;
/// msg - tracker message (there is no way of knowing what this message is - it's up to tracker admins)
@property (nonatomic, copy) NSString *  message;

@end


@interface QBitTorrentContent : NSObject<EKMappingProtocol>

/// File name
@property(nonatomic, copy) NSString *   name;
/// size - (translated string) file size
@property (nonatomic, copy) NSString *  size;
/// Float number for download completion percentage, where 1 == 100%, 0 == 0%, and, 0.58 == 58%
@property(nonatomic, assign) float      progress;
@property(nonatomic, assign) QBitTorrentContentPriority priority;
/// is_seed - only present for the first file in torrent; true if torrent is in seed mode
@property (nonatomic, assign) BOOL  isSeed;

@end


