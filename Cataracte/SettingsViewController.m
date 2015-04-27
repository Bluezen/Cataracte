//
//  SettingsViewController.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "SettingsViewController.h"
#import "CellWithColorscheme.h"
#import "AppDelegate.h"

typedef NS_ENUM(NSInteger, CellType) {
     CellTypeColorscheme,
};


@interface SettingsViewController ()<CellWithColorschemeDelegate>

@end


@implementation SettingsViewController


#pragma mark -  Lifecycle

- (instancetype)init
{
    return [super initWithTitle:NSLocalizedString(@"Settings", @"Settings")
                 tableStructure:@[
                                  @[
                                      @(CellTypeColorscheme),
                                      ],
                                  ]];
}

#pragma mark -  Overridden methods

- (void)registerCellsForTableView
{
    [self.tableView registerClass:[CellWithColorscheme class]
           forCellReuseIdentifier:[CellWithColorscheme reuseIdentifier]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeColorscheme) {
        return [self cellWithColorschemeIdAtIndexPath:indexPath];
    }
    
    return [UITableViewCell new];
}

#pragma mark -  UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellType type = [self cellTypeForIndexPath:indexPath];
    
    if (type == CellTypeColorscheme) {
        return [CellWithColorscheme height];
    }
    else {
        return 44.0;
    }
    
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -  CellWithColorschemeDelegate

- (void)cellWithColorscheme:(CellWithColorscheme *)cell didSelectScheme:(AppearanceManagerColorscheme)scheme
{
    [AppearanceManager changeColorschemeTo:scheme];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [delegate recreateControllersAndShow:AppDelegateTabIndexSettings];
}

#pragma mark -  Private

- (CellWithColorscheme *)cellWithColorschemeIdAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithColorscheme *cell = [self.tableView dequeueReusableCellWithIdentifier:[CellWithColorscheme reuseIdentifier]
                                                                     forIndexPath:indexPath];
    cell.delegate = self;
    
    [cell redraw];
    
    return cell;
}

@end
