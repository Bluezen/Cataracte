//
//  QBittorrentSettingsViewController.m
//  Cataracte
//
//  Created by Adrien Long on 23/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitSettingsViewController.h"
#import "CellWithTextInput.h"
#import "UserInfoManager.h"
#import "QBittorrentAPIManager.h"
#import "CellWithRightAlignedSubtitle.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeAddress,
    CellTypeUsername,
    CellTypePassword,
    CellTypePort,
    CellTypeAPIVersion,
};

@interface QBitSettingsViewController ()<CellWithTextInputDelegate>
@end

@implementation QBitSettingsViewController

#pragma mark - Lifecycle

-(instancetype)init
{
    return [super initWithTitle:NSLocalizedString(@"Settings", @"Settings")
                 tableStructure:@[
                                  @[
                                      @(CellTypeAddress),
                                      @(CellTypeUsername),
                                      @(CellTypePassword),
                                      @(CellTypePort),
                                      ],
                                  @[
                                      @(CellTypeAPIVersion),
                                      ]
                                  ]];
}

#pragma mark - Overridden methods

-(void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithTextInput class]
           forCellReuseIdentifier:[CellWithTextInput reuseIdentifier]];
    [self.tableView registerClass:[CellWithRightAlignedSubtitle class]
           forCellReuseIdentifier:[CellWithRightAlignedSubtitle reuseIdentifier]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeAddress || type == CellTypeUsername || type == CellTypePassword || type == CellTypePort)
    {
        return [self cellWithTextInputAtIndexPath:indexPath type:type];
    }
    else if (type == CellTypeAPIVersion)
    {
        return [self cellWithRightAlignedSubtitleAtIndexPath:indexPath type:type];
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeAddress ||
        type == CellTypeUsername ||
        type == CellTypePassword ||
        type == CellTypePort)
    {
        return [CellWithTextInput height];
    }
    else if(type == CellTypeAPIVersion)
    {
        return [CellWithTextInput height];
    }
    
    return 0.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - CellWithTextInputDelegate

-(void)cellWithTextInput:(CellWithTextInput *)cell textChangedTo:(NSString *)newTextInput
{
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    CellType type = [self cellTypeForIndexPath:path];
    
    if (type == CellTypeAddress) {
        [UserInfoManager sharedInstance].uQBittorrentHost = cell.textInput;
        [QBittorrentAPIManager resetSharedInstance];
    } else if (type == CellTypeUsername) {
        [UserInfoManager sharedInstance].uQBittorrentUsername = cell.textInput;
        [QBittorrentAPIManager resetSharedInstance];
    } else if (type == CellTypePassword) {
        [[QBittorrentAPIManager sharedInstance] switchWithConfigBlock:^(QBittorrentAPIManagerConfig *config)
        {
            config.m_password = cell.textInput;
        }];
    } else if (type == CellTypePort) {
        NSNumber *port = [[NSNumberFormatter new] numberFromString:cell.textInput];
        [UserInfoManager sharedInstance].uQBittorrentPort = port;
        [QBittorrentAPIManager resetSharedInstance];
    }
}

#pragma mark - Private

-(CellWithRightAlignedSubtitle *)cellWithRightAlignedSubtitleAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    CellWithRightAlignedSubtitle *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithRightAlignedSubtitle reuseIdentifier] forIndexPath:indexPath];
    
    if (type == CellTypeAPIVersion) {
        cell.textLabel.text = NSLocalizedString(@"qBittorrent Version", @"qBittorent Version - Settings");
        cell.detailTextLabel.text = NSStringFromQBittorrentVersion([QBittorrentAPIManager sharedInstance].currentConfig.m_version);
    }
    
    return cell;
}

-(CellWithTextInput *)cellWithTextInputAtIndexPath:(NSIndexPath *)indexPath type:(CellType)type
{
    CellWithTextInput *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithTextInput reuseIdentifier]
                                                                forIndexPath:indexPath];
    cell.delegate = self;
    
    if (type == CellTypeUsername) {
        cell.title = NSLocalizedString(@"Username", @"");
        cell.textInputPlaceholder = @"admin";
        cell.textInput = [QBittorrentAPIManager sharedInstance].currentConfig.m_username;
    } else if (type == CellTypePassword) {
        cell.title = NSLocalizedString(@"Password", @"");
        cell.textInputPlaceholder = @"**********";
        cell.isPassword = YES;
    } else if (type == CellTypeAddress) {
        cell.title = NSLocalizedString(@"Address", @"");
        cell.textInputPlaceholder = @"192.168.1.20";
        cell.textInput = [QBittorrentAPIManager sharedInstance].currentConfig.m_host;
    } else if (type == CellTypePort) {
        cell.title = NSLocalizedString(@"Port number", @"");
        cell.textInputPlaceholder = @"8080";
        cell.textInput = [QBittorrentAPIManager sharedInstance].currentConfig.m_port.stringValue;
        cell.textInputValidationRegex = @"^\\d+$";
        cell.textInputValidFormatMessage = NSLocalizedString(@"Port number must a digit number.", @"");
    }
    
    return cell;
}

@end
