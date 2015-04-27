//
//  BasicSettingsViewController.h
//  Cataracte
//
//  Created by Adrien Long on 22/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *tableStructure;

- (instancetype)initWithTitle:(NSString *)title tableStructure:(NSArray *)tableStructure;

- (NSIndexPath *)indexPathForCellType:(NSInteger)type;
- (NSInteger)cellTypeForIndexPath:(NSIndexPath *)indexPath;

#pragma mark -  Methods to override

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)registerCellsForTableView;

@end

