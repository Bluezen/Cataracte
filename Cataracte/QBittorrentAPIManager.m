//
//  QbittorentAPIManager.m
//  Cataracte
//
//  Created by Adrien Long on 13/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBittorrentAPIManager.h"
#import <AFNetworking/AFNetworking.h>
#import <EasyMapping/EasyMapping.h>

#import "UserInfoManager.h"

/// Used to decode responses, see initWithBuilder: of QbittorentAPIManager.
//static NSString const* kCONST_URI = @"/";
/// Used to decode responses, see initWithBuilder: of QbittorentAPIManager.
//static NSString const* kCONST_NONCE = @"a3f396f2dcc1cafae73637e2ac321134";

static QBittorrentAPIManager *__instance = nil;

NSString *NSStringFromQBittorrentVersion(QBittorrentVersion version) {
    NSDictionary * versionStrings =
    @{
      @(QBittorrentVersion_2_X) : @"2.x",
      @(QBittorrentVersion_3_1_X) : @"3.1.x",
      @(QBittorrentVersion_3_2_X) : @"3.2.x",
      };
    return [versionStrings objectForKey:@(version)];
}

@interface QBittorrentAPIManager ()
@property(nonatomic, strong) QBittorrentAPIManagerConfig *currentConfig;
@property(nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

+(instancetype)managerWithConfigBlock:(QBittorrentAPIManagerConfigBlock)block;
- (id)initWithBaseURL:(NSURL *)baseURL credential:(NSURLCredential *)credential;
- (id)initWithBuilder:(QBittorrentAPIManagerConfig *)config;
@end


@interface QBittorrentAPIManagerConfig ()
@property(nonatomic, strong) NSURL *baseURL;
@property(nonatomic, strong) NSURLProtectionSpace *loginProtectionSpace;
@property(nonatomic, strong) NSURLCredential *credential;
-(id)copyWithZone:(NSZone *)zone;
@end


@implementation QBittorrentAPIManagerConfig

#pragma mark - NSCopying

-(id)copyWithZone:(NSZone *)zone
{
    QBittorrentAPIManagerConfig *config = [[QBittorrentAPIManagerConfig allocWithZone:zone] init];
    config.m_host = self.m_host;
    config.m_port = self.m_port;
    config.m_username = self.m_username;
    config.m_password = self.m_password;
    config.m_version = self.m_version;
    return config;
}

#pragma mark - Private

-(QBittorrentAPIManager *)build
{
    NSAssert(self.m_host != nil, @"A host is required to build a QbittorentAPIManager.");
    
    NSString *urlString = nil;
    if (self.m_port) {
        urlString = [NSString stringWithFormat:@"http://%@:%@/", self.m_host, self.m_port];
    } else {
        [NSString stringWithFormat:@"http://%@:8080/", self.m_host];
    }
    self.baseURL = [NSURL URLWithString:urlString];
    
    self.loginProtectionSpace = [[NSURLProtectionSpace alloc]
                                 initWithHost:self.baseURL.host
                                 port:[self.baseURL.port integerValue]
                                 protocol:self.baseURL.scheme
                                 realm:@"Web UI Access"
                                 authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
    
    if (!self.m_username || !self.m_password) {
        NSDictionary *credentials;
        credentials = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:self.loginProtectionSpace];
        
        if (self.m_username) {
            self.credential = [credentials objectForKey:self.m_username];
        } else {
            // OK for now as we handle only one credential per space
            self.credential = [credentials.objectEnumerator nextObject];
        }
    } else {
        self.credential = [NSURLCredential
                           credentialWithUser:self.m_username
                           password:self.m_password
                           persistence:NSURLCredentialPersistencePermanent];
        [[NSURLCredentialStorage sharedCredentialStorage]
         setCredential:self.credential
         forProtectionSpace:self.loginProtectionSpace];
    }
    
    return [[QBittorrentAPIManager alloc] initWithBuilder:self];
}
@end

@implementation QBittorrentAPIManager

#pragma mark - Lifecycle

+ (instancetype)sharedInstance
{
    @synchronized(self) {
        if (__instance == nil)
        {
            __instance = [QBittorrentAPIManager managerWithConfigBlock:^(QBittorrentAPIManagerConfig *config) {
                config.m_username = [UserInfoManager sharedInstance].uQBittorrentUsername;
                config.m_host = [UserInfoManager sharedInstance].uQBittorrentHost;
                config.m_port = [UserInfoManager sharedInstance].uQBittorrentPort;
                config.m_version = [UserInfoManager sharedInstance].uQBittorrentVersion.unsignedIntegerValue;
            }];
        }
    }
    return __instance;
}

+(void)resetSharedInstance
{
    @synchronized(self) {
        __instance  = nil;
    }
}

-(instancetype)switchToConfig:(QBittorrentAPIManagerConfig *)config
{
    @synchronized(self){
        __instance = [config build];
    }
    return __instance;
}

-(instancetype)switchWithConfigBlock:(QBittorrentAPIManagerConfigBlock)block
{
    @synchronized(self){
        NSParameterAssert(block);
        
        QBittorrentAPIManagerConfig *config = [self.currentConfig copy];
        
        block(config);
        
        __instance = [config build];
    }
    return __instance;
}

- (id)initWithBuilder:(QBittorrentAPIManagerConfig *)config
{
    self = [self initWithBaseURL:config.baseURL credential:config.credential];
    if (self) {
        self.currentConfig = config;
    }
    return self;
}

- (id)initWithBaseURL:(NSURL *)baseURL credential:(NSURLCredential *)credential
{
    self = [super init];
    
    if (self) {
        self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        self.requestManager.credential = credential;
        
        AFJSONResponseSerializer *JSONRespSerializer = [AFJSONResponseSerializer serializer];
        
        AFHTTPResponseSerializer *HTTPRespSerializer = [AFHTTPResponseSerializer serializer];
        HTTPRespSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        
        AFCompoundResponseSerializer *CompoundRespSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[JSONRespSerializer, HTTPRespSerializer]];
        
        self.requestManager.responseSerializer = CompoundRespSerializer;
        
        AFHTTPRequestSerializer *requSerializer = [AFHTTPRequestSerializer serializer];
        [requSerializer setValue:@"Fiddler"     forHTTPHeaderField:@"User-Agent"];
        [requSerializer setValue:baseURL.host  forHTTPHeaderField:@"Host"];
        self.requestManager.requestSerializer = requSerializer;
        
        /*
         The following header seems USELESS with version 3.1.11 of qBittorrent
         https://github.com/qbittorrent/qBittorrent/wiki/WebUI-API-Documentation#authorization
         All fields in this header are required. Since nonce is not tracked by qBittorrent you should MD5-generate it yourself either one-time or each time you do any request. uri is not checked, if you want to GET host/someurl and uri doesn't match this value - no problem, just remember that uri is used in response generation.
         */
//        [_sessionManager.requestSerializer
//         setValue:[NSString stringWithFormat:@"Digest username=\"%@\", realm=\"Web UI Access\", nonce=\"%@\", uri=\"%@\", response=\"4067cfe4c029cd00b56076c78abd034c\"", config.m_username, kCONST_NONCE, kCONST_URI]
//         forHTTPHeaderField:@"Authorization"];
        
    }
    
    return self;
}

+(instancetype)managerWithConfigBlock:(QBittorrentAPIManagerConfigBlock)block
{
    NSParameterAssert(block);
    
    QBittorrentAPIManagerConfig *config = [QBittorrentAPIManagerConfig new];
    block(config);
    return [config build];
}

#pragma mark - Public

-(BFTask *)shutdownQbittorent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self GET:@"command/shutdown" parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
    {
        [bfTask setResult:@(op.response.statusCode)];
    } failure:^(AFHTTPRequestOperation *op, NSError *error)
    {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)getTorrentList
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *URLString = nil;
    if(self.currentConfig.m_version == QBittorrentVersion_3_2_X) {
        URLString = @"query/torrents";
    } else {
        URLString = @"json/torrents";
    }
    
    [self GET:URLString parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
     {
         NSArray *torrents;
         torrents = [EKMapper
                     arrayOfObjectsFromExternalRepresentation:res
                     withMapping:[QBitTorrent objectMapping]];
         [bfTask setResult:torrents];
     } failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}

-(BFTask *)getTorrentGenericInfo:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *URLString = nil;
    
    if(self.currentConfig.m_version == QBittorrentVersion_3_2_X) {
        URLString = [NSString stringWithFormat:@"query/propertiesGeneral/%@", torrent.hashId];
    } else {
        URLString = [NSString stringWithFormat:@"json/propertiesGeneral/%@", torrent.hashId];
    }
    
    [self GET:URLString parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
     {
         [EKMapper fillObject:torrent
   fromExternalRepresentation:res
                  withMapping:[QBitTorrent objectMapping]];
         [bfTask setResult:torrent];
     } failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}

-(BFTask *)getTorrentTrackers:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *URLString = nil;
    
    if(self.currentConfig.m_version == QBittorrentVersion_3_2_X) {
        URLString = [NSString stringWithFormat:@"query/propertiesTrackers/%@", torrent.hashId];
    } else {
        URLString = [NSString stringWithFormat:@"json/propertiesTrackers/%@", torrent.hashId];
    }
    
    [self GET:URLString parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
     {
         NSArray *trackers;
         trackers = [EKMapper
                     arrayOfObjectsFromExternalRepresentation:res
                     withMapping:[QBitTorrentTracker objectMapping]];
         torrent.trackers = trackers;
         [bfTask setResult:torrent];
     } failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}

-(BFTask *)getTorrentContents:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *URLString = nil;
    
    if(self.currentConfig.m_version == QBittorrentVersion_3_2_X) {
        URLString = [NSString stringWithFormat:@"query/propertiesFiles/%@", torrent.hashId];
    } else {
        URLString = [NSString stringWithFormat:@"json/propertiesFiles/%@", torrent.hashId];
    }
    
    [self GET:URLString parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
     {
         NSArray *contents;
         contents = [EKMapper
                     arrayOfObjectsFromExternalRepresentation:res
                     withMapping:[QBitTorrentContent objectMapping]];
         torrent.contents = contents;
         [bfTask setResult:torrent];
     } failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}

-(BFTask *)getGlobalTransferInfo
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *URLString = nil;
    
    if(self.currentConfig.m_version == QBittorrentVersion_3_2_X) {
        URLString = @"query/transferInfo";
    } else {
        URLString = @"json/transferInfo";
    }
    
    [self GET:URLString parameters:nil
      success:^(AFHTTPRequestOperation *op, id res)
     {
         QBitGlobalInfo *info;
         info = [EKMapper
                 objectFromExternalRepresentation:res
                 withMapping:[QBitGlobalInfo objectMapping]];
         [bfTask setResult:info];
     } failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}



-(BFTask *)downloadTorrentsFromLinks:(NSArray *)links
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    // From qBittorent API: "Links' contents must be escaped, e.g. & becomes %26 (don't know about other characters but ampersand MUST be escaped)"
    NSMutableString *urls = [NSMutableString string];
    
    NSUInteger i = 0;
    for (NSString *link in links) {
        [urls appendString:[link stringByReplacingOccurrencesOfString:@"&" withString:@"%26"]];
        if (links.count > 1 && i < (links.count - 1)) {
            [urls appendString:@"%0A"];
        }
        ++i;
    }
    
    [self POSTCommand:@"download"
           parameters:@{@"urls":urls}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)pauseTorrent:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"pause"
           parameters:@{@"hash":torrent.hashId}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)pauseAllTorrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"pauseall"
           parameters:nil
//     withContentTypeUrlEncoded:NO
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)resumeTorrent:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"resume"
           parameters:@{@"hash":torrent.hashId}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)resumeAllTorrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"resumeall"
           parameters:nil
//     withContentTypeUrlEncoded:NO
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)deleteTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"delete"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)deleteDownloadedDataAndTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"deletePerm"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)recheckTorrent:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"recheck"
           parameters:@{@"hash":torrent.hashId}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)increasePriorityOfTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"increasePrio"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)decreasePriorityOfTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"decreasePrio"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)setMaximalPriorityToTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"topPrio"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)setMinimalPriorityToTorrents:(NSArray *)torrents
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    NSString *hashes = [self hashesFromTorrents:torrents];
    
    [self POSTCommand:@"bottomPrio"
           parameters:@{@"hashes":hashes}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)setContentPriority:(QBitTorrentContentPriority)priority ofContentWithId:(NSInteger)idNumber fromTorrent:(QBitTorrent *)torrent
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"setFilePrio"
           parameters:@{@"hash":torrent.hashId,
                        @"id":@(idNumber),
                        @"priority":@(priority)
                        }
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)getGlobalDownloadLimit
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"getGlobalDlLimit"
           parameters:nil
     withContentTypeUrlEncoded:NO
              success:^(AFHTTPRequestOperation *op, id res)
    {
        NSString *resString = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
        
        [bfTask setResult:@(resString.intValue)];
    }
              failure:^(AFHTTPRequestOperation *op, NSError *error)
    {
        [bfTask setError:error];
    }];
    
    return bfTask.task;
}

-(BFTask *)setGlobalDownloadLimit:(NSInteger)bytes
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"setGlobalDlLimit"
           parameters:@{@"limit":@(bytes)}
       completionTask:bfTask];
    
    return bfTask.task;
}

-(BFTask *)getGlobalUploadLimit
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"getGlobalUpLimit"
           parameters:nil
     withContentTypeUrlEncoded:NO
              success:^(AFHTTPRequestOperation *op, id res)
     {
         NSString *resString = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
         [bfTask setResult:@(resString.intValue)];
     }
              failure:^(AFHTTPRequestOperation *op, NSError *error)
     {
         [bfTask setError:error];
     }];
    
    return bfTask.task;
}


-(BFTask *)setGlobalUploadLimit:(NSInteger)bytes
{
    BFTaskCompletionSource *bfTask = [BFTaskCompletionSource taskCompletionSource];
    
    [self POSTCommand:@"setGlobalUpLimit"
           parameters:@{@"limit":@(bytes)}
       completionTask:bfTask];
    
    return bfTask.task;
}

#pragma mark - Private



-(NSString *)hashesFromTorrents:(NSArray *)torrents
{
    NSMutableArray *hashesArray = [NSMutableArray arrayWithCapacity:torrents.count];
    for (QBitTorrent *torrent in torrents) {
        [hashesArray addObject:torrent.hashId];
    }
    
    return [hashesArray componentsJoinedByString:@"|"];
}

- (void)GET:(NSString *)URLString
                   parameters:(id)parameters
                      success:(void (^)(AFHTTPRequestOperation *op, id res))success
                      failure:(void (^)(AFHTTPRequestOperation *op, NSError *error))failure
{
    [self performHTTPRequestOperationkWithHTTPMethod:@"GET" requestSerializer:self.requestManager.requestSerializer URLString:URLString parameters:parameters success:success failure:failure];
    
}

- (void)POSTCommand:(NSString *)command
         parameters:(id)parameters
     completionTask:(BFTaskCompletionSource *)task
{
    [self POSTCommand:command
           parameters:parameters
withContentTypeUrlEncoded:YES
              success:^(AFHTTPRequestOperation *op, id res)
    {
        [task setResult:@(op.response.statusCode)];
    }
              failure:^(AFHTTPRequestOperation *op, NSError *error)
    {
        [task setError:error];
    }];
}

- (void)POSTCommand:(NSString *)command
         parameters:(id)parameters
withContentTypeUrlEncoded:(BOOL)hasHeader
            success:(void (^)(AFHTTPRequestOperation *op, id res))success
            failure:(void (^)(AFHTTPRequestOperation *op, NSError *error))failure
{
    AFHTTPRequestSerializer *requSerializer = nil;
    
    if (hasHeader) {
        requSerializer = [self.requestManager.requestSerializer copy];
        
        [requSerializer setValue:@"application/x-www-form-urlencoded"
          forHTTPHeaderField:@"Content-Type"];
    } else {
        requSerializer = self.requestManager.requestSerializer;
    }
    
    
    NSString *URLString = [NSString stringWithFormat:@"command/%@", command];
    
    [self performHTTPRequestOperationkWithHTTPMethod:@"POST"
                                   requestSerializer:requSerializer
                                           URLString:URLString
                                          parameters:parameters
                                             success:success
                                             failure:failure];
    
}

- (void)performHTTPRequestOperationkWithHTTPMethod:(NSString *)method
                                 requestSerializer:(AFHTTPRequestSerializer<AFURLRequestSerialization> *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                         success:(void (^)(AFHTTPRequestOperation *op, id res))success
                                         failure:(void (^)(AFHTTPRequestOperation *op, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request;
    request = [requestSerializer
               requestWithMethod:method
               URLString:[[NSURL URLWithString:URLString relativeToURL:self.requestManager.baseURL] absoluteString]
               parameters:parameters
               error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.requestManager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return;
    }
    
    AFHTTPRequestOperation *operation;
    operation = [self.requestManager
                 HTTPRequestOperationWithRequest:request
                 success:success failure:failure];
    [self.requestManager.operationQueue addOperation:operation];
}

@end
