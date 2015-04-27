//
//  SearchViewController.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeSearchesViewController.h"
#import "StrikeTorrentsListViewController.h"
#import "StrikeAPIManager.h"
#import "StrikeAddSearchViewController.h"
#import "UINavigationController+Utilities.h"
#import "CATSearch.h"
#import "StrikeSearchCell.h"
#import "UIAlertController+Cataracte.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface StrikeSearchesViewController ()
@property NSMutableArray *searches;
@end

@implementation StrikeSearchesViewController

#pragma mark - Lifecycle

-(id)init
{
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Searches", @"Searches");
        self.clearsSelectionOnViewWillAppear = NO;
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPresssed:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[StrikeSearchCell class] forCellReuseIdentifier:[StrikeSearchCell reuseIdentifier]];
    
    self.searches = [[CATSearch instancesOrderedBy:@"createdTime DESC"] mutableCopy];
}

#pragma mark - Public

-(void)insertSearch:(CATSearch *)search
{
    [self.searches insertObject:search atIndex:0];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self performSearch:search];
}

#pragma mark - Action

- (void)addButtonPresssed:(id)sender {
    if (!self.searches) {
        self.searches = [[NSMutableArray alloc] init];
    }
    
    StrikeAddSearchViewController *addSearchViewController = [StrikeAddSearchViewController new];
    addSearchViewController.searchViewController = self;
    
    [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:addSearchViewController] sender:self];

}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[StrikeSearchCell reuseIdentifier] forIndexPath:indexPath ];
    
    CATSearch *search = self.searches[indexPath.row];
    cell.textLabel.text = [search query];
    cell.detailTextLabel.text = [search category];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CATSearch *search = self.searches[indexPath.row];
        [self.searches removeObjectAtIndex:indexPath.row];
        [search delete];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATSearch *search = self.searches[indexPath.row];
    
    [self performSearch:search];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [StrikeSearchCell height];
}

#pragma mark - Private

-(void)performSearch:(CATSearch *)search
{
    [MBProgressHUD showHUDAddedTo:self.splitViewController.view animated:YES];
    
    [[[StrikeAPIManager sharedInstance] getSearch:search] continueWithBlock:^id(BFTask *task) {
        
        [MBProgressHUD hideHUDForView:self.splitViewController.view animated:YES];
        
        if (task.error != nil) {
            [self presentViewController:[UIAlertController alertStrikeAPINotOnlineWithOKAction:nil] animated:YES completion:nil];
            return nil;
        }
        
        NSArray *torrents = task.result;
        
        StrikeTorrentsListViewController *detail = [StrikeTorrentsListViewController new];
        [detail setTorrents:torrents];
        detail.title = [NSString stringWithFormat:@"%@ - %@", self.title, search.query];
        
        [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:detail] sender:self];
        
        return nil;
    }];
}

@end
