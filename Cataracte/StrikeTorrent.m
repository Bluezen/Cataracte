//
//  StrikeTorrent.m
//  Cataracte
//
//  Created by Adrien Long on 07/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeTorrent.h"
#import "NSDateFormatter+Utilities.h"
#import "StrikeAPIManager.h"
#import <TransformerKit/NSValueTransformer+TransformerKit.h>

NSString *const CATUnixTimestampToDateTransformer = @"CATDateTransformer";

@implementation StrikeTorrent

+ (void)load
{
    @autoreleasepool {        
        [NSValueTransformer
         registerValueTransformerWithName:CATUnixTimestampToDateTransformer
         transformedValueClass:[NSNumber class]
         returningTransformedValueWithBlock:^id(id value)
         {
             return [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
         }
         allowingReverseTransformationWithBlock:^id(id value)
         {
             return [NSNumber numberWithDouble:[(NSDate *)value timeIntervalSince1970]];
         }];
    }
}

#pragma mark - EKMappingProtocol

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {

        [mapping mapPropertiesFromArray:@[@"seeds", @"leeches", @"size"]];
        [mapping mapPropertiesFromDictionary:@{
            @"torrent_hash":@"hashId",
            @"torrent_title":@"title",
            @"torrent_category":@"category",
            @"sub_category":@"subCategory",
            @"file_count":@"fileCount",
            @"uploader_username":@"uploaderUsername",
            @"magnet_uri":@"magnetUri",
            @"file_info.file_names":@"fileNames",
            @"file_info.file_lengths":@"fileLengths"
        }];

        [mapping mapKeyPath:@"upload_date"
                 toProperty:@"uploadDate"
          withDateFormatter:[NSDateFormatter cat_formatterForCurrentThread]];
    }];
}

#pragma mark - FCModel

-(BOOL)save
{
    if (!self.createdTime) {
        self.createdTime = [NSDate date];
    }
    
    // We force fileNames and fileLengths fields to be fetched before insertion in local DB.
//    if (self.fileNames == nil || self.fileLengths == nil) {
//        return (BOOL)[[[StrikeAPIManager sharedInstance] getInfoFromTorrentsHashes:@[self.hashId]] continueWithBlock:^id(BFTask *task)
//        {
//            if (task.error) {
//                return [BFTask taskWithResult:@(NO)];
//            }
//            
//            StrikeTorrent *torrent = [(NSArray *)task.result firstObject];
//            
//            if (self.fileNames == nil) {
//                self.fileNames = [torrent.fileNames copy];
//            }
//            
//            if (self.fileLengths == nil) {
//                self.fileLengths = [torrent.fileLengths copy];
//            }
//            
//            torrent = nil;
//            
//            return [BFTask taskWithResult:@([super save])];
//        }].result;
//    }
    
    return [super save];
}

+(NSValueTransformer *)valueTransformerForFieldName:(NSString *)fieldName
{
    if ([fieldName isEqualToString:@"createdTime"] || [fieldName isEqualToString:@"uploadDate"]) {
        
        return [NSValueTransformer valueTransformerForName:CATUnixTimestampToDateTransformer];
    }
    
    return nil;
}

@end
