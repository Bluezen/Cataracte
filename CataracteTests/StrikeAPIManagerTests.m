//
//  StrikeAPIManagerTests.m
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StrikeAPIManager.h"
#import "StrikeTorrent.h"

@interface StrikeAPIManagerTests : XCTestCase
{
    StrikeAPIManager *_apiManager;
}

@end

@implementation StrikeAPIManagerTests

- (void)setUp {
    [super setUp];
    
    _apiManager = [StrikeAPIManager sharedInstance];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreationOfInstanceWithDefaultInitializerToBeNil {
    
    XCTAssertNil([StrikeAPIManager new], @"Pass");
}

- (void)testCorrectFetchOfInfo {
    
    XCTestExpectation *infoFetchedExpectation = [self expectationWithDescription:@"Info fetched"];
    
    [[_apiManager getInfoFromTorrentsHashes:@[@"B415C913643E5FF49FE37D304BBB5E6E11AD5101"]] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNotNil(task.result);
        
        NSArray *torrents = task.result;
        
        XCTAssertEqual(1, torrents.count);
        
        StrikeTorrent *torrent = torrents.firstObject;
        
        XCTAssertEqualObjects(torrent.hashId, @"B415C913643E5FF49FE37D304BBB5E6E11AD5101", @"Hashes must be equals");
        
        XCTAssertEqualObjects(torrent.title, @"Ubuntu 14.10 Desktop 64bit ISO", @"Titles must be equals");
        
        XCTAssertEqualObjects(torrent.category, @"Applications", @"Category must be equal");
        
        XCTAssertEqualObjects(torrent.subCategory, @"", @"SubCategory must be an empty string.");
        XCTAssertEqualObjects(torrent.magnetUri, @"magnet:?xt=urn:btih:B415C913643E5FF49FE37D304BBB5E6E11AD5101&dn=Ubuntu+14.10+Desktop+64bit+ISO&tr=udp://open.demonii.com:1337&tr=udp://tracker.coppersurfer.tk:6969&tr=udp://tracker.leechers-paradise.org:6969&tr=udp://exodus.desync.com:6969");
        
        XCTAssertEqual(torrent.fileCount, 1);
        XCTAssertEqual(torrent.size, 1159641170);
        
//        CATFileInfo *fileInfo = torrent.fileInfo;
//        
//        XCTAssertNotNil(fileInfo);
//        
//        XCTAssertEqualObjects(fileInfo.fileNames.firstObject, @"ubuntu-14.10-desktop-amd64.iso");
//        
//        XCTAssertEqualObjects(fileInfo.fileLengths.firstObject, @(1162936320));
        
        XCTAssertEqualObjects(torrent.fileNames.firstObject, @"ubuntu-14.10-desktop-amd64.iso");
        
        XCTAssertEqualObjects(torrent.fileLengths.firstObject, @(1162936320));
        
        [infoFetchedExpectation fulfill];
        
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:3 handler:^(NSError *error) {
        
    }];
}
/* */
- (void)testCorrectFetchOfDescriptionAndCorrectDecode {
    
    XCTestExpectation *descFetchedExpectation = [self expectationWithDescription:@"Description fetched"];
    
    [[_apiManager getDescriptionFromTorrentHash:@"B415C913643E5FF49FE37D304BBB5E6E11AD5101"] continueWithBlock:^id(BFTask *task) {
        
        XCTAssertNotNil(task.result);
        
        NSString *utf8String = task.result;
        
        NSData *plainData = [utf8String dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [plainData base64EncodedStringWithOptions:0];
        
        XCTAssertEqualObjects(base64String, @"CgkJCQkJCQk8aW1nIGNsYXNzPSJsYXp5anMgYmJjb2RlSW1hZ2UiIHNyYz0iaHR0cDovL2dldHN0cmlrZS5uZXQvaW1nL2JsYW5rLmdpZiIgZGF0YS1vcmlnaW5hbD0iaHR0cDovL3d3dy50ZWphc2Jhcm90LmNvbS93cC1jb250ZW50L3VwbG9hZHMvL1VidW50dTE0MTAuanBnIiBhbHQ9ImltYWdlIiAvPjxiciAvPg0KPGltZyBjbGFzcz0ibGF6eWpzIGJiY29kZUltYWdlIiBzcmM9Imh0dHA6Ly9nZXRzdHJpa2UubmV0L2ltZy9ibGFuay5naWYiIGRhdGEtb3JpZ2luYWw9Imh0dHA6Ly9jZG4tc3RhdGljLnpkbmV0LmNvbS9pL3Ivc3RvcnkvNzAvMDAvMDMzMDE5LzE0MTAtZGVza3RvcC12MS02MjB4Mzg4LmpwZyIgYWx0PSJpbWFnZSIgLz48YnIgLz4NCjxpbWcgY2xhc3M9ImxhenlqcyBiYmNvZGVJbWFnZSIgc3JjPSJodHRwOi8vZ2V0c3RyaWtlLm5ldC9pbWcvYmxhbmsuZ2lmIiBkYXRhLW9yaWdpbmFsPSJodHRwOi8vd3d3Lm9tZ3VidW50dS5jby51ay93cC1jb250ZW50L3VwbG9hZHMvMjAxNC8wNi91dG9waWMtdW5pY29ybi0zNTB4MjAwLmpwZyIgYWx0PSJpbWFnZSIgLz48YnIgLz4NCkludHJvZHVjdGlvbjxiciAvPg0KPGJyIC8+DQpUaGVzZSByZWxlYXNlIG5vdGVzIGZvciBVYnVudHUgMTQuMTAgKFV0b3BpYyBVbmljb3JuKSBwcm92aWRlIGFuIG92ZXJ2aWV3IG9mIHRoZSByZWxlYXNlIGFuZCBkb2N1bWVudCB0aGUga25vd24gaXNzdWVzIHdpdGggVWJ1bnR1IDE0LjEwIGFuZCBpdHMgZmxhdm9ycy48YnIgLz4NCjxiciAvPg0KU3VwcG9ydCBsaWZlc3BhbjxiciAvPg0KPGJyIC8+DQpVYnVudHUgMTQuMTAgd2lsbCBiZSBzdXBwb3J0ZWQgZm9yIDkgbW9udGhzIGZvciBVYnVudHUgRGVza3RvcCwgVWJ1bnR1IFNlcnZlciwgVWJ1bnR1IENvcmUsIEt1YnVudHUsIFVidW50dSBLeWxpbiBhbG9uZyB3aXRoIGFsbCBvdGhlciBmbGF2b3Vycy4gPGJyIC8+DQo8YnIgLz4NCjxiciAvPg0KVXBkYXRlZCBQYWNrYWdlczxiciAvPg0KTGludXgga2VybmVsIDMuMTY8YnIgLz4NCkFwcEFybW9yPGJyIC8+DQpPeGlkZTxiciAvPg0KVW5pdHk8YnIgLz4NCkxpYnJlT2ZmaWNlPGJyIC8+DQpVYnVudHUgRGV2ZWxvcGVyIFRvb2xzIENlbnRlcjxiciAvPg0KWG9yZwoJCQkJCQk8L2Rpdj4KCQkJCSAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgPGRpdiBpZD0iX2E5ZGExYTdjYjAwNGEwMjhmOTZkOGY4NDc1YjM0MDFkIj48L2Rpdj4KICAgICAgICAgICAgICAgIAkJCQkJPC9kaXY+CgkJCQkJCQkJCQkgICAgICAgICAgICAJ", @"Pass");
        
        [descFetchedExpectation fulfill];
        
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:4 handler:^(NSError *error) {
        
    }];
}
/* */

@end
