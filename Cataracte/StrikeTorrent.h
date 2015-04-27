//
//  StrikeTorrent.h
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "FCModel.h"
#import <EasyMapping/EasyMapping.h>


@interface StrikeTorrent : FCModel<EKMappingProtocol>

#pragma mark - Properties mapped from Strike API

@property(nonatomic, copy) NSString *   hashId;
@property(nonatomic, copy) NSString *   title;
@property(nonatomic, strong) NSDate *   uploadDate;
@property(nonatomic, copy) NSString *   category;
@property(nonatomic, copy) NSString *   subCategory;
@property(nonatomic, assign) NSUInteger seeds;
@property(nonatomic, assign) NSUInteger leeches;
@property(nonatomic, assign) NSUInteger fileCount;
@property(nonatomic, assign) int64_t    size;
@property(nonatomic, copy) NSString *   uploaderUsername;
@property(nonatomic, strong) NSArray *  fileNames;
@property(nonatomic, strong) NSArray *  fileLengths;
@property(nonatomic, copy) NSString *   magnetUri;
@property(nonatomic, copy) NSString *   rawDescription;

#pragma mark - SQLite properties

@property(nonatomic, strong) NSDate *createdTime;
/// Will save instance in DB if doesn't exist yet.
@property(nonatomic, assign) BOOL bookmarked;

@end
