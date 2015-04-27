//
//  TopsViewController.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeTopsViewController.h"
#import "StrikeTorrentsListViewController.h"
#import "StrikeAPIManager.h"
#import "UIViewController+CATViewControllerShowing.h"
#import "AppearanceManager.h"
#import "UINavigationController+Utilities.h"
#import "UIAlertController+Cataracte.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString *const kStrikeTopsViewControllerCellIdentifier = @"kStrikeTorrentsListCellIdentifier";

@interface StrikeTopsViewController ()
@property(nonatomic, strong) NSArray *categories;
@end

@implementation StrikeTopsViewController

#pragma mark - Lifecycle

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        self.title = NSLocalizedString(@"Tops", @"Tops");
        self.clearsSelectionOnViewWillAppear = NO;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

#pragma mark - View Controller

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows) {
        BOOL indexPathPushes = [self cat_willShowingDetailViewControllerPushWithSender:self];
        if (indexPathPushes) {
            // If we're pushing for this indexPath, deselect it when we appear.
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kStrikeTopsViewControllerCellIdentifier];
    
    //Load the categories from disk
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Strike" withExtension:@"plist"];
    NSDictionary *strikeDictionary = [[NSDictionary alloc] initWithContentsOfURL:url];
    
    self.categories = strikeDictionary[@"categories"];
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDetailTargetDidChange:) name:UIViewControllerShowDetailTargetDidChangeNotification object:nil];
}

#pragma mark - Properties

- (void)showDetailTargetDidChange:(NSNotification *)notification
{
    // Whenever the target for showDetailViewController: changes, update all of our cells (to ensure they have the right accessory type).
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self tableView:self.tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStrikeTopsViewControllerCellIdentifier forIndexPath:indexPath];
    
    BOOL pushes = [self cat_willShowingDetailViewControllerPushWithSender:self];
    if (pushes) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *category = self.categories[indexPath.row];
    cell.textLabel.text = category;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *category = self.categories[indexPath.row];
    
    [MBProgressHUD showHUDAddedTo:self.splitViewController.view animated:YES];
    
    [[[StrikeAPIManager sharedInstance] getTopForCategory:category] continueWithBlock:^id(BFTask *task) {
        
        [MBProgressHUD hideHUDForView:self.splitViewController.view animated:YES];
        
        if (task.error) {
            [self presentViewController:[UIAlertController alertStrikeAPINotOnlineWithOKAction:nil] animated:YES completion:nil];
            return nil;
        }
        
        NSArray *torrents = task.result;
        
        StrikeTorrentsListViewController *detail = [StrikeTorrentsListViewController new];
        [detail setTorrents:torrents];
        detail.title = [NSString stringWithFormat:@"%@ - %@", self.title, category];
        
        [self.splitViewController showDetailViewController:[UINavigationController navControllerWithRoot:detail] sender:self];
        
        return nil;
    }];

}

@end
