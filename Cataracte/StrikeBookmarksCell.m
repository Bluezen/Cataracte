//
//  BookmarksCell.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeBookmarksCell.h"
#import "AppearanceManager.h"
#import "StrikeTorrent.h"
#import "NSDateFormatter+Utilities.h"

@implementation StrikeBookmarksCell

#pragma mark -  Lifecycle

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.font = [AppearanceManager fontNormalWithSize:20];
        self.textLabel.numberOfLines = 2;
        self.detailTextLabel.numberOfLines = 3;
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
        
        self.textLabel.text = torrent.title;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ - %@ %@\n%@  --  %@  --  %lu %@", torrent.category, NSLocalizedString(@"uploaded by", @"uploaded by"), torrent.uploaderUsername, [[NSDateFormatter cat_formatterForCurrentThread] stringFromDate:torrent.uploadDate], [NSByteCountFormatter stringFromByteCount:torrent.size countStyle:NSByteCountFormatterCountStyleFile], (unsigned long)torrent.fileCount, torrent.fileCount > 1 ? NSLocalizedString(@"files", @"files") : NSLocalizedString(@"file", @"file")]];
        
        self.detailTextLabel.attributedText = text;
        
        [self adjustSubviews];
    }
}

#pragma mark - Public

+ (CGFloat)height
{
    return 90.0;
}

#pragma mark -  Private

- (void)adjustSubviews
{
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 5.0;
    self.detailTextLabel.frame = frame;
}


@end
