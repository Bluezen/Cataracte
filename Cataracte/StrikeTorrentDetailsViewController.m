//
//  TorrentDetailsViewController.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeTorrentDetailsViewController.h"
//#import "UIView+Utilities.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIViewController+Utilities.h"
#import "StrikeTorrent.h"
#import "StrikeAPIManager.h"
#import "UIAlertController+Cataracte.h"
#import "UINavigationController+Utilities.h"

@interface StrikeTorrentDetailsViewController ()

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) UITextView *textView;

@end

@implementation StrikeTorrentDetailsViewController

#pragma mark -  Lifecycle

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.title = NSLocalizedString(@"Details", @"Details");
    }
    
    return self;
}

#pragma mark - View controller

- (void)loadView
{
    [self loadWhiteView];
    
    [self createScrollView];
    [self createTextView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self adjustSubviews];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.presentingViewController)
    {
        UIBarButtonItem *doneButton;
        doneButton = [UIBarButtonItem.alloc
                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                      target:self
                      action:@selector(doneButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = doneButton;
    }
    
    [self configureViewWithTorrent:self.torrent];
}

#pragma mark - Action

-(void)doneButtonPressed:(UIBarButtonItem *)item {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Properties

-(void)setTorrent:(StrikeTorrent *)torrent
{
    if (torrent != _torrent) {
        _torrent = torrent;
        
         [self configureViewWithTorrent:torrent];
    }
}

#pragma mark -  Private

- (void)configureViewWithTorrent:(StrikeTorrent *)torrent
{
    if (torrent == nil || !self.isViewLoaded) return;
    
    if (torrent.rawDescription) {
        
        NSString *htmlString = torrent.rawDescription;
        
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        self.textView.attributedText = attributedString;
        [self adjustSubviews];
        
    } else {
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        [[[StrikeAPIManager sharedInstance] getDescriptionFromTorrentHash:self.torrent.hashId] continueWithBlock:^id(BFTask *task) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (task.error != nil) {
                [self presentViewController:[UIAlertController alertStrikeAPINotOnlineWithOKAction:nil] animated:YES completion:nil];
                return nil;
            }
            
            torrent.rawDescription = task.result;
            [torrent save];
            
            [self configureViewWithTorrent:torrent];
            
            return nil;
        }];
        
    }
}

- (void)createScrollView
{
    self.scrollView = [UIScrollView new];
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
}

- (void)createTextView
{
    self.textView = [UITextView new];
    self.textView.scrollEnabled = NO;
    self.textView.editable = NO;
    [self.scrollView addSubview:self.textView];
}

- (void)adjustSubviews
{
    self.scrollView.frame = self.view.bounds;
    
    CGFloat currentOriginY = 0.0;
    const CGFloat yIndentation = 10.0;
    
    CGRect frame = self.scrollView.frame;
    
    {
        CGSize size = [self.textView sizeThatFits:CGSizeMake(CGRectGetWidth(frame), CGFLOAT_MAX)];
        frame.size.height = size.height;
        frame.origin.x = 10.0;
        frame.origin.y = currentOriginY + yIndentation;
        self.textView.frame = frame;
    }
    currentOriginY = CGRectGetMaxY(frame);
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), currentOriginY + yIndentation);
}


@end
