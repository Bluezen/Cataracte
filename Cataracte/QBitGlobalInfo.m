//
//  QBitGlobal.m
//  Cataracte
//
//  Created by Adrien Long on 16/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitGlobalInfo.h"

@implementation QBitGlobalInfo

#pragma mark - EKMappingProtocol

+(EKObjectMapping *)objectMapping
{
    return [EKObjectMapping mappingForClass:self withBlock:^(EKObjectMapping *mapping) {
        
        [mapping mapPropertiesFromDictionary:@{
                                               @"dl_info":@"dlInfo",
                                               @"up_info":@"upInfo",
                                               
                                               @"dl_info_speed":@"dlSpeed",
                                               @"dl_info_data":@"dlData",
                                               @"up_info_speed":@"upSpeed",
                                               @"up_info_data":@"upData",
                                               @"dl_rate_limit":@"dlRateLimit",
                                               @"up_rate_limit":@"upRateLimit",
                                               @"dht_nodes":@"dhtNodes"
                                               }];
        
        NSDictionary *status = @{
                                 @"connected": @(QBitGlobalInfoConnectionStatusConnected),
                                 @"firewalled": @(QBitGlobalInfoConnectionStatusFirewalled),
                                 @"disconnected": @(QBitGlobalInfoConnectionStatusDisconnected)
                                 };
        [mapping mapKeyPath:@"status" toProperty:@"status" withValueBlock:^(NSString *key, id value) {
            return status[value];
        } reverseBlock:^id(id value) {
            return [status allKeysForObject:value].lastObject;
        }];
    }];
}

@end
