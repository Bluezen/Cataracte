//
//  QBittorrentMenuViewController.m
//  Cataracte
//
//  Created by Adrien Long on 21/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitMenuViewController.h"
#import "UINavigationController+Utilities.h"
#import "UIViewController+CATViewControllerShowing.h"
#import "QBitSettingsViewController.h"
#import "QBittorrentAPIManager.h"
#import "UserInfoManager.h"
#import "MBProgressHUD+Utilities.h"

typedef NS_ENUM(NSInteger, CellType) {
    CellTypeAll,
    CellTypeDownloading,
    CellTypeFinished,
    CellTypeStopped,
    CellTypeOptions,
    CellTypeSettings,
};

static NSString *const kTitleCellReuseIdentifier = @"kTitleCellReuseIdentifier";

@interface QBitMenuViewController ()
@property(nonatomic, strong) NSArray *menuItems;
@end

@implementation QBitMenuViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super initWithTitle:NSLocalizedString(@"qBittorrent Client", @"Title of QBittorentMenuViewController: qBittorent Client")
                 tableStructure:@[
                                  @[
                                      @(CellTypeAll),
                                      @(CellTypeDownloading),
                                      @(CellTypeFinished),
                                      @(CellTypeStopped),
                                      ],
                                  @[
//                                      @(CellTypeOptions),
                                      @(CellTypeSettings),
                                      ]
                                  ]];
    if (self)
    {
        
    }
    return self;
}

#pragma mark - Public

-(void)addTorrentWithMagnet:(NSString *)magnetLink
{
    [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    
    [[[[QBittorrentAPIManager sharedInstance]
      downloadTorrentsFromLinks:@[magnetLink]]
     continueWithBlock:^id(BFTask *task)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[self indexPathForCellType:CellTypeAll]];
        [cell setSelected:YES animated:YES];
        return [self presentTorrentsListWithType:CellTypeAll];
    }] continueWithBlock:^id(BFTask *task)
    {
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
        if (!task.result) {
            // TODO: display "NO Result"
        } else if (task.error) {
            // TODO: display error
        }
        return nil;
    }];
}

#pragma mark - Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTitleCellReuseIdentifier];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeAll ||
        type == CellTypeDownloading ||
        type == CellTypeFinished ||
        type == CellTypeStopped ||
        type == CellTypeOptions ||
        type == CellTypeSettings)
    {
        return [self cellWithTitleAtIndexPath:indexPath withType:type];
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeAll ||
        type == CellTypeDownloading ||
        type == CellTypeFinished ||
        type == CellTypeStopped ||
        type == CellTypeOptions ||
        type == CellTypeSettings)
    {
        return 44;
    }
    
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeAll ||
        type == CellTypeDownloading ||
        type == CellTypeFinished ||
        type == CellTypeStopped)
    {
        [self presentTorrentsListWithType:type];
    } else if (type == CellTypeOptions) {
        
    } else if (type == CellTypeSettings) {
        QBitSettingsViewController *settingsViewController = [QBitSettingsViewController new];
        
        [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:settingsViewController] sender:self];
    }
}

#pragma mark - QBitTorrentsListViewControllerDelegate

-(void)qBitTorrentsListViewControllerRefreshButtonPushed:(QBitTorrentsListViewController *)viewController
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    
    CellType type = [self cellTypeForIndexPath:selectedRowIndexPath];
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:viewController.view.window];
    hud.graceTime = 1;
    [hud show:YES];
    
    [[self getTorrentsForType:type] continueWithBlock:^id(BFTask *task) {
        
        [MBProgressHUD hideHUDForView:viewController.view.window animated:YES];
        
        NSArray *torrents = task.result;
        
        if (torrents.count == 0) {
            [MBProgressHUD showForOneSecondHUDAddedTo:viewController.view.window withText:NSLocalizedString(@"No Result", @"No Result")];
        }
        
        viewController.torrents = torrents;
        
        return nil;
    }];
}

#pragma mark - Private

- (UITableViewCell *)cellWithTitleAtIndexPath:(NSIndexPath *)indexPath withType:(CellType)type
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kTitleCellReuseIdentifier
                                                                 forIndexPath:indexPath];
    
    if (type == CellTypeAll) {
        cell.textLabel.text = NSLocalizedString(@"All", @"All");
    } else if (type == CellTypeDownloading) {
        cell.textLabel.text = NSLocalizedString(@"Downloading", @"Downloading");
    } else if (type == CellTypeFinished) {
        cell.textLabel.text = NSLocalizedString(@"Finished", @"Finished");
    } else if (type == CellTypeStopped) {
        cell.textLabel.text = NSLocalizedString(@"Stopped", @"Stopped");
    } else if (type == CellTypeOptions) {
        cell.textLabel.text = NSLocalizedString(@"Options", @"Options");
    } else if (type == CellTypeSettings) {
        cell.textLabel.text = NSLocalizedString(@"Settings", @"Settings");
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.textLabel.textColor = [UIColor blackColor];
    
    BOOL pushes = [self cat_willShowingDetailViewControllerPushWithSender:self];
    if (pushes) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(BFTask *)presentTorrentsListWithType:(CellType)type
{
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view.window];
    hud.graceTime = 1;
    [hud show:YES];
    
    return [[self getTorrentsForType:type] continueWithBlock:^id(BFTask *task) {
        
        [MBProgressHUD hideHUDForView:self.view.window animated:YES];
        
        NSArray *torrents = task.result;
        
        if (task.error) {
            return [BFTask taskWithError:task.error];
        } else if (!torrents) {
            return [BFTask taskWithResult:nil];
        }
        
        QBitTorrentsListViewController *torrentsListVC = [QBitTorrentsListViewController new];
        
        torrentsListVC.torrents = torrents;
        torrentsListVC.delegate = self;
        
        if (type == CellTypeAll) {
            torrentsListVC.title = NSLocalizedString(@"All", @"All");
        } else if (type == CellTypeDownloading) {
            torrentsListVC.title = NSLocalizedString(@"Downloading", @"Downloading");
        } else if (type == CellTypeFinished) {
            torrentsListVC.title = NSLocalizedString(@"Finished", @"Finished");
        } else if (type == CellTypeStopped) {
            torrentsListVC.title = NSLocalizedString(@"Stopped", @"Stopped");
        }
        
        if (torrentsListVC.torrents.count == 0) {
            [MBProgressHUD showForOneSecondHUDAddedTo:self.view.window withText:NSLocalizedString(@"No Result", @"No Result")];
        }
        
        [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:torrentsListVC] sender:self];
        
        return [BFTask taskWithResult:torrents];
    }];
}

-(BFTask *)getTorrentsForType:(CellType)type
{
    return [[[QBittorrentAPIManager sharedInstance] getTorrentList] continueWithBlock:^id(BFTask *task) {
        
        NSArray *torrents = task.result;
        
        if (task.error) {
            return [BFTask taskWithError:task.error];
        } else if (!torrents) {
            return [BFTask taskWithResult:nil];
        }
        
        if (type == CellTypeDownloading) {
            torrents = [torrents objectsAtIndexes:[torrents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
            {
                QBitTorrent *torrent = obj;
                return  torrent.state == QBitTorrentStateDownloading ||
                        torrent.state == QBitTorrentStateStalledDL;
            }]];
        } else if (type == CellTypeFinished) {
            torrents = [torrents objectsAtIndexes:[torrents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
            {
                QBitTorrent *torrent = obj;
                return  torrent.state == QBitTorrentStateCheckingUP ||
                        torrent.state == QBitTorrentStatePausedUP;
                
            }]];
        } else if (type == CellTypeStopped) {
            torrents = [torrents objectsAtIndexes:[torrents indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
            {
                QBitTorrent *torrent = obj;
                return  torrent.state == QBitTorrentStateError ||
                        torrent.state == QBitTorrentStatePausedDL ||
                        torrent.state == QBitTorrentStatePausedUP;
            }]];
        }
        
        return [BFTask taskWithResult:torrents];
    }];
}

@end
