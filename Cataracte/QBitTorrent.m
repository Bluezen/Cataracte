//
//  QBitTorrent.m
//  Cataracte
//
//  Created by Adrien Long on 15/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitTorrent.h"

@implementation QBitTorrent

#pragma mark - EKMappingProtocol

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        
        [mapping mapPropertiesFromArray:@[
                                          @"name", @"size", @"progress", @"priority", @"ratio", @"eta",
                                          @"path", @"comment"
                                          ]];
        [mapping mapPropertiesFromDictionary:@{
                                               @"hash":@"hashId",
                                               @"torrent_title":@"title",
                                               @"dlspeed":@"dlSpeed",
                                               @"upspeed":@"upSpeed",
                                               @"num_seeds":@"nbSeeds",
                                               @"num_leechs":@"nbLeechs",
                                               
                                               @"creation_date":@"creationDate",
                                               @"piece_size":@"pieceSize",
                                               @"total_wasted":@"totalWasted",
                                               @"total_uploaded":@"upTotal",
                                               @"total_downloaded":@"dlTotal",
                                               @"up_limit":@"upSpeedLimit",
                                               @"dl_limit":@"dlSpeedLimit",
                                               @"time_elapsed":@"timeElapsed",
                                               @"nb_connections":@"nbConnections",
                                               @"share_ratio":@"shareRatio"
                                               }];
        
        NSDictionary *states = @{
                                 @"error": @(QBitTorrentStateError),
                                 @"pausedUP": @(QBitTorrentStatePausedUP),
                                 @"pausedDL": @(QBitTorrentStatePausedDL),
                                 @"queuedUP": @(QBitTorrentStateQueuedUP),
                                 @"queuedDL": @(QBitTorrentStateQueuedDL),
                                 @"uploading": @(QBitTorrentStateUploading),
                                 @"stalledUP": @(QBitTorrentStateStalledUP),
                                 @"checkingUP": @(QBitTorrentStateCheckingUP),
                                 @"checkingDL": @(QBitTorrentStateCheckingDL),
                                 @"downloading": @(QBitTorrentStateDownloading),
                                 @"stalledDL": @(QBitTorrentStateStalledDL)
                                 };
        [mapping mapKeyPath:@"state" toProperty:@"state" withValueBlock:^(NSString *key, id value) {
            return states[value];
        } reverseBlock:^id(id value) {
            return [states allKeysForObject:value].lastObject;
        }];
        
    }];
}

@end

@implementation QBitTorrentTracker

#pragma mark - EKMappingProtocol

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        
        [mapping mapPropertiesFromArray:@[@"status"]];
        [mapping mapPropertiesFromDictionary:@{
                                               @"num_peers":@"nbPeers",
                                               @"msg":@"message"
                                               }];
        
        [mapping mapKeyPath:@"url" toProperty:@"url"
             withValueBlock:[EKMappingBlocks urlMappingBlock]
               reverseBlock:[EKMappingBlocks urlReverseMappingBlock]];
        
    }];
}

@end


@implementation QBitTorrentContent

#pragma mark - EKMappingProtocol

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        
        [mapping mapPropertiesFromArray:@[@"name", @"size", @"progress"]];
        [mapping mapPropertiesFromDictionary:@{
                                               @"is_seed":@"isSeed"
                                               }];
        
//        NSDictionary *priorities = @{
//                                 @(0): @(QBitTorrentContentPriorityDoNotDownload),
//                                 @(1): @(QBitTorrentContentPriorityNormal),
//                                 @(2): @(QBitTorrentContentPriorityHigh),
//                                 @(7): @(QBitTorrentContentPriorityMaximal)
//                                 };
        [mapping mapKeyPath:@"priority" toProperty:@"priority" withValueBlock:^(NSString *key, id value) {
            return value;
//            return priorities[value];
        } reverseBlock:^id(id value) {
            return value;
//            return [priorities allKeysForObject:value].lastObject;
        }];
        
    }];
}

@end




