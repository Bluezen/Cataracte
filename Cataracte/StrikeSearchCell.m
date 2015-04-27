//
//  SearchCell.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "StrikeSearchCell.h"
#import "AppearanceManager.h"

@implementation StrikeSearchCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.textLabel.font = [AppearanceManager fontNormalWithSize:20];
        self.textLabel.numberOfLines = 1;
        self.detailTextLabel.numberOfLines = 1;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return self;
}

#pragma mark -  Public

+ (CGFloat)height
{
    return 60.0;
}

@end
