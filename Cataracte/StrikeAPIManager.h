//
//  StrikeAPIManager.h
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Bolts/Bolts.h>
#import "StrikeTorrent.h"
#import "CATSearch.h"

@interface StrikeAPIManager : NSObject

+(instancetype)sharedInstance;

/**
 Async method to fetch infos of torrents. Will update database if saved entries could be filled with new data or updated with more recent data.
 @param hashes Array of torrents' hashes. Max is currently set to 50 (version 2 of API).
 @return BFTask with task.result an array of StrikeTorrent.
 **/
-(BFTask *)getInfoFromTorrentsHashes:(NSArray *)hashes;

/**
 Async method to fetch a link to a physical torrent file.
 @param hash Hash string of torrent.
 @return BFTask with task.result a URL string toward torrent file.
 **/
-(BFTask *)getDownloadLinkFromTorrentHash:(NSString *)hash;

/**
 Async method to fetch a torrent description.
 @param hash Hash string of torrent.
 @return BFTask with task.result a string that should contains HTML.
 **/
-(BFTask *)getDescriptionFromTorrentHash:(NSString *)hash;

/**
 Async method to fetch the total number of indexed torrents.
 @return BFTask with task.result an NSNumber of total indexed torrents.
 **/
-(BFTask *)getCountTotal;

/**
 Async method to fetch a list of top torrent files in specified category.
 @note WARNING: In current API version, file_names and file_lengths are not included in the torrents informations of the GET Top entry. You can retrieve these info by performing a getInfoFromTorrentsHashes:.
    Will update database if saved entries could be updated with more recent data.
 @param category Optional category string. If nil the category is set by default to 'all'. To get a valid list of categories go to https://getstrike.net/api/.
 @return BFTask with task.result an array of StrikeTorrent.
 **/
-(BFTask *)getTopForCategory:(NSString *)category;

/**
 Async method to perform a search query. Result is limited to 100.
 @param search The phrase to search.
 @return BFTask with task.result an array of StrikeTorrent.
 **/
-(BFTask *)getSearch:(CATSearch *)search;

@end
