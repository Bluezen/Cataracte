//
//  TorrentsListViewController.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeTorrentsListViewController.h"
#import "StrikeTorrent.h"
#import "StrikeTorrentsListCell.h"
#import "AppearanceManager.h"
#import "StrikeTorrentDetailsViewController.h"
#import "UINavigationController+Utilities.h"
#import "AppDelegate+Cataracte.h"

@interface StrikeTorrentsListViewController ()<UIActionSheetDelegate>

@end

@implementation StrikeTorrentsListViewController

#pragma mark - Lifecycle

-(id)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - View Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[StrikeTorrentsListCell class] forCellReuseIdentifier:[StrikeTorrentsListCell reuseIdentifier]];
    
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES; // needed on iPhone
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView {
    // Update the user interface.
    if (self.torrents) {
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Properties

-(void)setTorrents:(NSArray *)torrents
{
    if (torrents != _torrents) {
        _torrents = torrents;
        
        [self configureView];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.torrents.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [StrikeTorrentsListCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StrikeTorrentsListCell *cell = [tableView dequeueReusableCellWithIdentifier:[StrikeTorrentsListCell reuseIdentifier] forIndexPath:indexPath];
    
    cell.torrent = self.torrents[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    
    StrikeTorrentsListCell *cell = (StrikeTorrentsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString * buttonBookmarkTitle = cell.torrent.bookmarked? NSLocalizedString(@"Un-Bookmark", @"Un-Bookmark"): NSLocalizedString(@"Bookmark", @"Bookmark");
    
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc] initWithTitle:(isPhone?cell.torrent.title:nil)
                                              delegate:self
                                     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                destructiveButtonTitle:nil
                                     otherButtonTitles:NSLocalizedString(@"Open description", @"Open description"),
                   buttonBookmarkTitle,
                   NSLocalizedString(@"Add to download", @"Add to download"),
                   nil];
    
    
    if (isPhone) {
        [actionSheet showInView:tableView];
    } else {
        CGRect rect = cell.contentView.frame;
        rect = CGRectMake(CGRectGetMidX(rect), CGRectGetMidY(rect), 1.f, 1.f);
        [actionSheet showFromRect:rect inView:cell animated:YES];
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSIndexPath *selectedRowIndexPath = self.tableView.indexPathForSelectedRow;
    StrikeTorrentsListCell *cell = (StrikeTorrentsListCell *)[self.tableView cellForRowAtIndexPath:selectedRowIndexPath];
    StrikeTorrent *torrent = cell.torrent;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Open description",nil)]) {
        StrikeTorrentDetailsViewController *vc = [StrikeTorrentDetailsViewController new];
        vc.torrent = torrent;
        UINavigationController *nav = [UINavigationController navControllerWithRoot:vc];
        nav.modalPresentationStyle = UIModalPresentationFormSheet;
        // Prevent issue rdar://17742017 (See http://stackoverflow.com/questions/24854802/presenting-a-view-controller-modally-from-an-action-sheets-delegate-in-ios8 )
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:nav animated:YES completion:nil];
        });
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Add to download",nil)])
    {
        if (torrent.magnetUri) {
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [delegate switchToDownloadTabAndShowTorrentsListViewControllerWithMagnetLink:torrent.magnetUri];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Can't add this torrent", @"") message:NSLocalizedString(@"This torrent has not magnet link.", @"") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:nil];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Bookmark",nil)]) {
        torrent.bookmarked = YES;
        [torrent save];
        [(UIButton *)cell.accessoryView setSelected:YES];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Un-Bookmark",nil)]) {
        torrent.bookmarked = NO;
        [torrent save];
        [(UIButton *)cell.accessoryView setSelected:NO];
    }
}

@end
