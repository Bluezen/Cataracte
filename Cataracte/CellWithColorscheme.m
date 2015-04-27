//
//  CellWithColorscheme.m
//  Cataracte
//
//  Created by Adrien Long on 22/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "CellWithColorscheme.h"

#import "UIView+Utilities.h"
#import "UIColor+Utilities.h"

static const CGFloat kButtonSide = 40.0;
static const CGFloat kButtonIndentation = 15.0;

@interface CellWithColorscheme()

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) NSArray *buttonsArray;

@end

@implementation CellWithColorscheme

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.label = [self.contentView addLabelWithTextColor:[UIColor blackColor] bgColor:[UIColor clearColor]];
        self.label.text = NSLocalizedString(@"Colorscheme", @"CellWithColorscheme");
        
        [self createButtons];
    }
    return self;
}

#pragma mark -  Actions

- (void)buttonPressed:(UIButton *)button
{
    NSUInteger index = [self.buttonsArray indexOfObject:button];
    
    [self.delegate cellWithColorscheme:self didSelectScheme:index];
}

#pragma mark -  Public

- (void)redraw
{
    [self adjustSubviews];
}

+ (CGFloat)height
{
    return 70.0;
}

#pragma mark -  Private

- (void)createButtons
{
    NSMutableArray *array = [NSMutableArray new];
    AppearanceManagerColorscheme currentScheme = [AppearanceManager colorscheme];
    
    for (NSUInteger index = 0; index < __AppearanceManagerColorschemeCount; index++) {
        CGRect frame = CGRectZero;
        frame.size.width = frame.size.height = kButtonSide;
        
        UIButton *button = [[UIButton alloc] initWithFrame:frame];
        button.layer.cornerRadius = kButtonSide / 2;
        button.layer.masksToBounds = YES;
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        [array addObject:button];
        
        if (index == currentScheme) {
            button.layer.borderWidth = 2.0;
            button.layer.borderColor = [UIColor uColorOpaqueWithWhite:182].CGColor;
        }
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        subview.backgroundColor = [AppearanceManager textMainColorForScheme:index];
        subview.userInteractionEnabled = NO;

        [button addSubview:subview];
    }
    
    self.buttonsArray = [array copy];
}

- (void)adjustSubviews
{
    [self.label sizeToFit];
    
    CGRect frame = self.label.frame;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    self.label.frame = frame;
    
    const CGFloat buttonsWidth = self.buttonsArray.count * kButtonSide +
    (self.buttonsArray.count - 1) * kButtonIndentation;
    CGFloat originX = (self.bounds.size.width - buttonsWidth) / 2;
    
    for (NSUInteger index = 0; index < self.buttonsArray.count; index++) {
        UIButton *button = self.buttonsArray[index];
        
        frame = button.frame;
        frame.origin.x = originX;
        frame.origin.y = CGRectGetMaxY(self.label.frame) + 5.0;
        button.frame = frame;
        
        originX += kButtonSide + kButtonIndentation;
    }
}

@end

