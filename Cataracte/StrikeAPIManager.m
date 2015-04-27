//
//  StrikeAPIManager.m
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeAPIManager.h"
#import "AFHTTPSessionManager.h"
#import "NSString+Utilities.h"

static NSString * const kStrikeAPIv2URLString = @"https://getstrike.net/api/v2/";

@implementation StrikeAPIManager
{
    AFHTTPSessionManager *_sessionManager;
}

#pragma mark - Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    self = [super init];
    
    if (self) {
        NSURL *URL = [NSURL URLWithString:kStrikeAPIv2URLString];
        
        _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:URL];
        
        _sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    return self;
}

+(instancetype)sharedInstance
{
    static StrikeAPIManager *sharedManager;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        sharedManager = [[StrikeAPIManager alloc] initPrivate];
    });
    
    return sharedManager;
}

#pragma mark - Public

-(BFTask *)getInfoFromTorrentsHashes:(NSArray *)hashes
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hash = [hashes componentsJoinedByString:@","];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"hashes"] = hash;
    
    [_sessionManager GET:@"torrents/info/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *repTorrents = [(NSDictionary *)responseObject objectForKey:@"torrents"];
        
        [bfTask setResult:[self torrentsFromExternalRepresentation:repTorrents]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getDownloadLinkFromTorrentHash:(NSString *)hash
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"hash"] = hash;
    
    [_sessionManager GET:@"torrents/download/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        [bfTask setResult:[dict objectForKey:@"message"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getDescriptionFromTorrentHash:(NSString *)hash
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"hash"] = hash;
    
    [_sessionManager GET:@"torrents/descriptions/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSString *base64String = [(NSDictionary *)responseObject objectForKey:@"message"];
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
        
        [bfTask setResult:decodedString];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getCountTotal
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [_sessionManager GET:@"torrents/count/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSString *countString = [dict objectForKey:@"message"];
        [bfTask setResult:@([countString integerValue])];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getTopForCategory:(NSString *)category
{
    
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"category"] = category ? category : @"all";
    
    [_sessionManager GET:@"torrents/top/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *repTorrents = [(NSDictionary *)responseObject objectForKey:@"torrents"];
        
        [bfTask setResult:[self torrentsFromExternalRepresentation:repTorrents]];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getSearch:(CATSearch *)search
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"phrase"] = [search.query stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (search.category && ![search.category isEqual:@"All"]) {
        parameters[@"category"] = search.category;
    }
    
    if (search.subCategory) {
        parameters[@"subcategory"] = search.subCategory;
    }
    
    [_sessionManager GET:@"torrents/search/" parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *repTorrents = [(NSDictionary *)responseObject objectForKey:@"torrents"];

        [bfTask setResult:[self torrentsFromExternalRepresentation:repTorrents]];

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

#pragma mark - Private

-(NSArray *)torrentsFromExternalRepresentation:(NSArray *)torrentsRepresentations
{
    NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:torrentsRepresentations.count];
    
    int i = 0;
    for (NSDictionary *torrentRepresentation in torrentsRepresentations) {
        torrents[i] = [StrikeTorrent instanceWithPrimaryKey:torrentRepresentation[@"torrent_hash"]];
        ++i;
    }
    
    i = 0;
    for (StrikeTorrent *torrent in torrents) {
        [EKMapper fillObject:torrent fromExternalRepresentation:torrentsRepresentations[i] withMapping:[StrikeTorrent objectMapping]];
        ++i;
        if (torrent.hasUnsavedChanges && torrent.existsInDatabase) {
            [torrent save];
        }
    }
    
    return torrents;
}

@end
