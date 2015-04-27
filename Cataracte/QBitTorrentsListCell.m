//
//  QBitTorrentsListCell.m
//  Cataracte
//
//  Created by Adrien Long on 24/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "QBitTorrentsListCell.h"
#import "AppearanceManager.h"
#import "QBitTorrent.h"

@implementation QBitTorrentsListCell

#pragma mark -  Lifecycle

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textLabel.font = [AppearanceManager fontBoldWithSize:18];
        self.textLabel.numberOfLines = 2;
        
        self.detailTextLabel.font = [AppearanceManager fontNormalWithSize:12];
        self.detailTextLabel.numberOfLines = 2;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    return self;
}

#pragma mark - View

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubviews];
}

#pragma mark - Properties

-(void)setTorrent:(QBitTorrent *)torrent
{
    if (torrent != _torrent) {
        _torrent = torrent;
        
        switch (torrent.state) {
            case QBitTorrentStateDownloading:
                self.imageView.image = [UIImage imageNamed:@"downloading"];
                break;
            case QBitTorrentStateUploading:
                self.imageView.image = [UIImage imageNamed:@"uploading"];
                break;
            default:
                self.imageView.image = [UIImage imageNamed:@"paused"];
                break;
        }
        
        // Update cell content with torrent data
        self.textLabel.text = torrent.name;
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ \n %@ ", [self torrentStateDescription], [self torrentProgressStatusDescription]]];
        
        self.detailTextLabel.attributedText = text;
        
        // Ajuste cell layout with new content
        [self adjustSubviews];
    }
}

#pragma mark - Public

+(CGFloat)height
{
    return 100.0;
}

#pragma mark -  Private

- (void)adjustSubviews
{
    CGRect frame = self.detailTextLabel.frame;
    frame.origin.y = CGRectGetMaxY(self.textLabel.frame) + 5.0;
    self.detailTextLabel.frame = frame;
}

-(NSString *)torrentStateDescription
{
    QBitTorrentState state = self.torrent.state;
    
    if (state == QBitTorrentStateUploading) {
        return NSLocalizedString(@"seeding", @"");
    } else if (state == QBitTorrentStateDownloading) {
        return [NSString stringWithFormat:@"%@, %@ %@", NSLocalizedString(@"downloading", @""), NSLocalizedString(@"ETA", @"ETA - estimated time of arrival"), self.torrent.eta];
    }
    
    return NSLocalizedString(@"closed", @"");
}

-(NSString *)torrentProgressStatusDescription
{
    QBitTorrentState state = self.torrent.state;
    
    NSNumber *progressPercent = [NSNumber numberWithFloat:self.torrent.progress * 100];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:0];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    
    if (state == QBitTorrentStateUploading) {
        return [NSString stringWithFormat:@"%@ (%@%%) - UP at %@", self.torrent.size, [formatter stringFromNumber:progressPercent], self.torrent.upSpeed];
    } else if (state == QBitTorrentStateDownloading) {
        NSNumber *torrentSize = [formatter numberFromString:self.torrent.size];
        NSNumber *sizeDownloaded = [NSNumber numberWithFloat:self.torrent.progress * torrentSize.floatValue];
        
        return [NSString stringWithFormat:@"%@ of %@ (%@%%) - DL at %@", [formatter stringFromNumber:sizeDownloaded], self.torrent.size, [formatter stringFromNumber:progressPercent], self.torrent.dlSpeed];
    }
    
    return [NSString stringWithFormat:@"%@%% of %@", [formatter stringFromNumber:progressPercent], self.torrent.size];
}

@end
