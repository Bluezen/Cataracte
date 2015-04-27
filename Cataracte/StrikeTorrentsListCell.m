//
//  TorrentsListCell.m
//  Cataracte
//
//  Created by Adrien Long on 08/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeTorrentsListCell.h"
#import "AppearanceManager.h"
#import "StrikeTorrent.h"
#import "NSDateFormatter+Utilities.h"
#import "MBProgressHUD+Utilities.h"

@interface StrikeTorrentsListCell()

@property(nonatomic, strong) UIButton *bookmarkButton;

@end

@implementation StrikeTorrentsListCell

#pragma mark -  Lifecycle

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.font = [AppearanceManager fontNormalWithSize:20];
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.numberOfLines = 4;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self createBookmarkButton];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubviews];
}

#pragma mark -  Properties

-(void)setTorrent:(StrikeTorrent *)torrent
{
    if (torrent != _torrent) {
        _torrent = torrent;
        
        // Update cell content with torrent data
        self.textLabel.text = torrent.title;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@ %@\n%@  --  %@  --  %lu %@\nLeeches: %lu Seeds: %lu", torrent.category, NSLocalizedString(@"uploaded by", @"uploaded by"), torrent.uploaderUsername, [[NSDateFormatter cat_formatterForCurrentThread] stringFromDate:torrent.uploadDate], [NSByteCountFormatter stringFromByteCount:torrent.size countStyle:NSByteCountFormatterCountStyleFile], (unsigned long)torrent.fileCount, torrent.fileCount > 1 ? NSLocalizedString(@"files", @"files") : NSLocalizedString(@"file", @"file"), (unsigned long)torrent.leeches, (unsigned long)torrent.seeds]];
        
        self.detailTextLabel.attributedText = text;
        
        self.bookmarkButton.selected = torrent.bookmarked;
        
        // Ajuste cell layout with new content
        [self adjustSubviews];
    }
}

#pragma mark - Public

+ (CGFloat)height
{
    return 120.0;
}

#pragma mark - Actions

-(void)bookmarkButtonPressed:(UIButton *)button
{
    NSString *text = !button.selected ?
        NSLocalizedString(@"Bookmarked!",@"Bookmarked!") :
        NSLocalizedString(@"Un-Bookmarked!",@"Un-Bookmarked!");
    [MBProgressHUD showForOneSecondHUDAddedTo:self.window withText:text];
    
    // Saving torrent shouldn't take much time that is why we keep it on main thread but just to ensure the immediat display of the HUD to give the feeling saving's already done we delay it. We don't check for possible failure of saving... yet.
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.torrent.bookmarked = !button.selected;
        [self.torrent save];
        [button setSelected:self.torrent.bookmarked];
    });
}

#pragma mark -  Private

- (void)createBookmarkButton
{
    self.bookmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];

    UIImage *bookmarkImage = [UIImage imageNamed:@"bookmarkButton"];
    UIImage *bookmarkedImage = [UIImage imageNamed:@"bookmarkedButton"];
    
    self.bookmarkButton.bounds = CGRectMake(0, 0, bookmarkImage.size.width, bookmarkImage.size.height);
    
    [self.bookmarkButton setImage:[bookmarkImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    [self.bookmarkButton setImage:[bookmarkedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateSelected];
    
    [self.bookmarkButton addTarget:self action:@selector(bookmarkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.accessoryView = self.bookmarkButton;
}

- (void)adjustSubviews
{
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 5.0;
    self.detailTextLabel.frame = frame;
}


@end
