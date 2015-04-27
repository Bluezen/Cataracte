//
//  BasicSettingsViewController.m
//  Cataracte
//
//  Created by Adrien Long on 22/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StaticTableViewController.h"
#import "UIViewController+Utilities.h"

#define OVERRIDE_METHOD @throw \
[NSException exceptionWithName:NSInternalInconsistencyException \
reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] \
userInfo:nil];

@interface StaticTableViewController ()
@end

@implementation StaticTableViewController

#pragma mark -  Lifecycle

- (instancetype)initWithTitle:(NSString *)title tableStructure:(NSArray *)tableStructure
{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.tableStructure = tableStructure;
    }
    
    return self;
}

- (void)loadView
{
    [self loadWhiteView];
    
    [self createTableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self adjustSubviews];
}

#pragma mark -  Public

- (NSIndexPath *)indexPathForCellType:(NSInteger)type
{
    for (NSUInteger section = 0; section < self.tableStructure.count; section++) {
        NSArray *subArray = self.tableStructure[section];
        
        for (NSUInteger row = 0; row < subArray.count; row++) {
            NSNumber *number = subArray[row];
            
            if (number.integerValue == type) {
                return [NSIndexPath indexPathForRow:row inSection:section];
            }
        }
    }
    
    return nil;
}

- (NSInteger)cellTypeForIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *number = self.tableStructure[indexPath.section][indexPath.row];
    return number.unsignedIntegerValue;
}

#pragma mark -  UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OVERRIDE_METHOD
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.tableStructure.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArray = self.tableStructure[section];
    return subArray.count;
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (section == 0) ? 20.0 : 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0;
}

#pragma mark -  Private

- (void)createTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    [self registerCellsForTableView];
    
    [self.view addSubview:self.tableView];
}

- (void)registerCellsForTableView
{
    OVERRIDE_METHOD
}

- (void)adjustSubviews
{
    self.tableView.frame = self.view.bounds;
}

@end
