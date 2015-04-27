//
//  AddSearchViewController.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeAddSearchViewController.h"
#import "UIView+Utilities.h"
#import "UIViewController+Utilities.h"
#import "AppearanceManager.h"
#import "CATSearch.h"
#import "StrikeSearchesViewController.h"

@interface StrikeAddSearchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) UILabel *searchLabel;
@property(nonatomic, strong) UITextField *searchTextField;

@property(nonatomic, strong) UILabel *categoriesLabel;
@property(nonatomic, strong) UITableView *categoriesTabelView;

@property(nonatomic, strong) UIButton *addSearchButton;

// Data
@property(nonatomic, strong) NSArray *categories;
@property(nonatomic, strong) NSString *selectedCategory;

@end

@implementation StrikeAddSearchViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Add", @"Add Search");
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"Strike" withExtension:@"plist"];
        NSDictionary *strikeDictionary = [[NSDictionary alloc] initWithContentsOfURL:url];
        
        self.categories = strikeDictionary[@"categories"];
        self.selectedCategory = self.categories.firstObject;
    }
    
    return self;
}

- (void)loadView
{
    [self loadWhiteView];
    
    [self createScrollView];
    [self createSearchViews];
    [self createCategoriesViews];
    [self createAddSearchButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self adjustSubviews];
}

#pragma mark -  Actions

- (void)addSearchButtonPressed
{
    if (self.searchTextField.text.length < 3) {
        return;
    }
    
    CATSearch *search = [CATSearch new];
    search.query = self.searchTextField.text;
    search.category = self.selectedCategory;
    search.createdTime = [NSDate date];
    [search save];
    
    [self.searchViewController insertSearch:search];
    
//    if (self.splitViewController.isCollapsed) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
}

- (void)finishEditingButtonPressed
{
    if (self.searchTextField.isFirstResponder) {
        [self.searchTextField resignFirstResponder];
    }
}

#pragma mark - Table View

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSString *category = self.categories[indexPath.row];
    
    if ([self.selectedCategory isEqual:category]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.text = category;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
    [self.categoriesTabelView reloadData];
}

#pragma mark -  UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.searchTextField]) {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(finishEditingButtonPressed)];
    }
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.searchTextField]) {
        
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:self.searchTextField]) {
        if ([string isEqual:@"\n"]) {
            [textField resignFirstResponder];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -  Private

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
}

- (void)createSearchViews
{
    self.searchLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                          bgColor:[UIColor clearColor]];
    self.searchLabel.text = NSLocalizedString(@"Enter search request:", @"Enter search request");
    
    self.searchTextField = [UITextField new];
    self.searchTextField.tintColor = [AppearanceManager tintColor];
    self.searchTextField.delegate = self;
    self.searchTextField.backgroundColor = [UIColor lightGrayColor];
    [self.scrollView addSubview:self.searchTextField];
}

- (void)createCategoriesViews
{
    self.categoriesLabel = [self.scrollView addLabelWithTextColor:[UIColor blackColor]
                                                            bgColor:[UIColor clearColor]];
    self.categoriesLabel.text = NSLocalizedString(@"Choose a category:", @"");
    
    self.categoriesTabelView = [UITableView new];
    self.categoriesTabelView.dataSource = self;
    self.categoriesTabelView.delegate   = self;
    self.categoriesTabelView.backgroundColor = [UIColor clearColor];
    [self.categoriesTabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.scrollView addSubview:self.categoriesTabelView];
}

- (void)createAddSearchButton
{
    self.addSearchButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addSearchButton setTitle:NSLocalizedString(@"Add search request", @"Add search request") forState:UIControlStateNormal];
    [self.addSearchButton addTarget:self
                               action:@selector(addSearchButtonPressed)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.addSearchButton];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;
    
    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;
    
    CGRect frame = CGRectZero;
    
    {
        [self.searchLabel sizeToFit];
        frame = self.searchLabel.frame;
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + yIndentation;
        self.searchLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    {
        const CGFloat xIndentation = self.searchLabel.frame.origin.x;
        
        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        frame.size.height = 40.0;
        self.searchTextField.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    
    {
        [self.categoriesLabel sizeToFit];
        frame = self.categoriesLabel.frame;
        frame.origin.x = self.searchLabel.frame.origin.x;
        frame.origin.y = currentOriginY + yIndentation;
        self.categoriesLabel.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    
    [self.addSearchButton sizeToFit];
    const CGFloat addSearchButtonHeight = self.addSearchButton.frame.size.height;
    
    {
        const CGFloat xIndentation = self.searchLabel.frame.origin.x;
        
        frame = CGRectZero;
        frame.origin.x = xIndentation;
        frame.origin.y = currentOriginY + yIndentation;
        frame.size.width = self.view.bounds.size.width - 2 * xIndentation;
        frame.size.height = self.scrollView.bounds.size.height - self.scrollView.contentInset.top -
        self.scrollView.contentInset.bottom - frame.origin.y - addSearchButtonHeight - 2 * yIndentation;
        self.categoriesTabelView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    
    {
        frame = self.addSearchButton.frame;
        frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
        frame.origin.y = currentOriginY + yIndentation;;
        self.addSearchButton.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.origin.x, currentOriginY + yIndentation);
}

@end
