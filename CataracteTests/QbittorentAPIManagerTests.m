//
//  QbittorentAPIManagerTests.m
//  Cataracte
//
//  Created by Adrien Long on 14/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "QBittorrentAPIManager.h"

@interface QbittorentAPIManagerTests : XCTestCase
{
    QBittorrentAPIManager *_manager;
}
@end

@implementation QbittorentAPIManagerTests

- (void)setUp {
    [super setUp];
    
    _manager = [[QBittorrentAPIManager sharedInstance] switchWithConfigBlock:^(QBittorrentAPIManagerConfig *config) {
        config.m_host = @"192.168.1.47";
        config.m_port = @(8080);
        config.m_username = @"admin";
        config.m_password = @"azerty";
        config.m_version = QBittorrentVersion_3_1_X;
    }];
}

- (void)tearDown {
    [super tearDown];
    
    _manager = nil;
}

-(void)test01_QBittorrentIsReachable
{
    XCTAssertNotNil(_manager, @"QBittorent API Manager wasn't created.");
}

- (void)test05_GETTorrentLists {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[_manager getTorrentList] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        NSArray *torrents = task.result;
        
        for (QBitTorrent *torrent in torrents) {
            XCTAssertNotNil(torrent.hashId, @"\n\n___README___\nQBitTorrent must have an hashId not nil");
        }
        
        [infoFetchedExpectation fulfill];
        
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        
    }];
}

- (void)test06_GETTorrentGenericInfo {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[[_manager getTorrentList] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        NSArray *torrents = task.result;
        
        QBitTorrent *torrent = torrents.firstObject;
        
        return [_manager getTorrentGenericInfo:torrent];
    }] continueWithBlock:^id(BFTask *task) {
      
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        QBitTorrent *torrent = task.result;
        
        XCTAssertNotNil(torrent.shareRatio, @"\n\n___README___\nQBitTorrent must have a shareRatio not nil");
        
        [infoFetchedExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}

- (void)test07_GETTorrentTrackers {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[[_manager getTorrentList] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        NSArray *torrents = task.result;
        
        QBitTorrent *torrent = torrents.firstObject;
        
        return [_manager getTorrentTrackers:torrent];
    }] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        QBitTorrent *torrent = task.result;
        
        XCTAssertNotNil(torrent.trackers, @"\n\n___README___\nQBitTorrentTrackers must not be nil");
        
        QBitTorrentTracker *tracker = torrent.trackers.firstObject;
        
        XCTAssertNotNil(tracker.url, @"\n\n___README___\nQBitTorrentTracker must have a url not nil");
        
        [infoFetchedExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}

- (void)test08_GETTorrentContents {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[[_manager getTorrentList] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        NSArray *torrents = task.result;
        
        QBitTorrent *torrent = torrents.firstObject;
        
        return [_manager getTorrentContents:torrent];
    }] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        QBitTorrent *torrent = task.result;
        
        XCTAssertNotNil(torrent.contents, @"\n\n___README___\nQBitTorrentContents must not be nil");
        
        QBitTorrentContent *content = torrent.contents.firstObject;
        
        XCTAssertNotNil(content.name, @"\n\n___README___\nQBitTorrentContent must have a name not nil");
        
        [infoFetchedExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        
    }];
}

- (void)test30_POSTGlobalTransferInfo {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[_manager getGlobalTransferInfo] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        QBitGlobalInfo *info = task.result;
        
        XCTAssertTrue((info.dlInfo != nil) | (info.dhtNodes > 0 && info.dhtNodes < 1000), @"\n\n___README___\nQBitGlobalInfo must have a dlInfo not nil");
        
        [infoFetchedExpectation fulfill];
        
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        
    }];
}

-(void)test40_POSTDownloadTorrent {
 
    NSString *magnetLink1 = @"magnet:?xt=urn:btih:B7EC88F005D4F922156DF52CBFDC0A8CDB44CBC5&dn=The+Water+Diviner+%282014%29+%5B1080p%5D&tr=http%3A%2F%2Ftracker.yify-torrents.com%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.org%3A80&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337";
    
    NSString *magnetLink2 = @"magnet:?xt=urn:btih:1FC7726B937C03F1B812C4D4C8251F657B28B811&dn=Nightcrawler+%282014%29+%5B1080p%5D&tr=http%3A%2F%2Ftracker.yify-torrents.com%2Fannounce&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.org%3A80&tr=udp%3A%2F%2Ftracker.coppersurfer.tk%3A6969&tr=udp%3A%2F%2Ftracker.leechers-paradise.org%3A6969&tr=udp%3A%2F%2Fopen.demonii.com%3A1337&tr=udp%3A%2F%2Fp4p.arenabg.ch%3A1337&tr=udp%3A%2F%2Fp4p.arenabg.com%3A1337";
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[_manager downloadTorrentsFromLinks:@[magnetLink1, magnetLink2]] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        XCTAssert([task.result isEqualToNumber:@(200)], @"\n\n___README___\nTask result has a different value than 200: %@", task.result);
        
        [infoFetchedExpectation fulfill];
        
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        
    }];
}

-(void)test31_POSTGlobalDownloadLimit
{    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[_manager getGlobalDownloadLimit] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
        
        XCTAssert([task.result isKindOfClass:[NSNumber class]], @"\n\n___ README ___\nTask should return a number.");
        
        [infoFetchedExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        
    }];
}

// - (void)test90_ShutdownQbittorent {
// 
//     XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
//     
//     [[_manager shutdownQbittorent] continueWithBlock:^id(BFTask *task) {
//         
//         XCTAssertNil(task.error, @"\n\n___ README ___\nTask returned an error: %@", task.error);
//         
//         XCTAssert([task.result isEqualToNumber:@(200)], @"\n\n___README___\nTask result has a different value than 200: %@", task.result);
//         
//         [infoFetchedExpectation fulfill];
//         
//         return nil;
//     }];
//     
//     [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
//         
//     }];
// }

@end
