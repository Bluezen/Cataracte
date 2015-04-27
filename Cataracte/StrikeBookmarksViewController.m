//
//  BookmarksViewController.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeBookmarksViewController.h"
#import "StrikeTorrent.h"
#import "StrikeBookmarksCell.h"
#import "StrikeTorrentDetailsViewController.h"
#import "UINavigationController+Utilities.h"

@interface StrikeBookmarksViewController ()
@property(nonatomic, strong) NSMutableArray *torrents;
@end

@implementation StrikeBookmarksViewController

#pragma mark - Lifecycle

-(id)init
{
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Bookmarks", @"Bookmarks");
        self.clearsSelectionOnViewWillAppear = NO;
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
    }
    
    return self;
}

#pragma mark - View Controller

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[StrikeBookmarksCell class] forCellReuseIdentifier:[StrikeBookmarksCell reuseIdentifier]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.torrents = [[StrikeTorrent instancesWhere:@"bookmarked == 1 ORDER BY createdTime DESC"] mutableCopy];
    [self.tableView reloadData];
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.torrents.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StrikeBookmarksCell *cell = [tableView dequeueReusableCellWithIdentifier:[StrikeBookmarksCell reuseIdentifier] forIndexPath:indexPath];
    
    cell.torrent = self.torrents[indexPath.row];
    
    return cell;
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        StrikeTorrent *torrent = self.torrents[indexPath.row];
        [torrent delete];
        [self.torrents removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StrikeTorrent *torrent = self.torrents[indexPath.row];
    
    StrikeTorrentDetailsViewController *detail = [StrikeTorrentDetailsViewController new];
    [detail setTorrent:torrent];
    
    [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:detail] sender:self];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [StrikeBookmarksCell height];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Private

@end
