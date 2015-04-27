//
//  QBitTorrentsList.m
//  Cataracte
//
//  Created by Adrien Long on 24/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitTorrentsListViewController.h"
#import "QBitTorrentsListCell.h"
#import "UIViewController+Utilities.h"

@interface QBitTorrentsListViewController ()
@end

@implementation QBitTorrentsListViewController
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
    
    [self.tableView registerClass:[QBitTorrentsListCell class] forCellReuseIdentifier:[QBitTorrentsListCell reuseIdentifier]];
    
    [self configureNaviguationBar];
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    // Update the user interface.
    if (self.torrents) {
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

-(void)configureNaviguationBar
{
    self.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
    self.navigationItem.leftItemsSupplementBackButton = YES; // needed on iPhone

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonPushed:)];
    
    self.navigationItem.rightBarButtonItem = refreshButton;
}

#pragma mark - Properties

-(void)setTorrents:(NSArray *)torrents
{
    _torrents = torrents;
    
    [self configureView];
}

#pragma mark - Actions

-(void)refreshButtonPushed:(UIBarButtonItem *)button
{
    if ([self.delegate respondsToSelector:@selector(qBitTorrentsListViewControllerRefreshButtonPushed:)]) {
        [self.delegate qBitTorrentsListViewControllerRefreshButtonPushed:self];
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
    return [QBitTorrentsListCell height];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBitTorrentsListCell *cell = [tableView dequeueReusableCellWithIdentifier:[QBitTorrentsListCell reuseIdentifier] forIndexPath:indexPath];
    
    cell.torrent = self.torrents[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    QBitTorrentsListCell *cell = (QBitTorrentsListCell *)[tableView cellForRowAtIndexPath:indexPath];
    
}

@end
