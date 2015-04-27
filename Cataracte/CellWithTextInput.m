//
//  CellWithTextInput.m
//  Cataracte
//
//  Created by Adrien Long on 23/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "CellWithTextInput.h"
#import "AppearanceManager.h"

@interface CellWithTextInput() <UITextFieldDelegate>

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UITextField *textInputField;

@end

@implementation CellWithTextInput

#pragma mark -  Lifecycle

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createLabel];
        [self createTextField];
    }
    return self;
}

#pragma mark -  View

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self adjustSubviews];
}


#pragma mark -  Properties

-(void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

-(NSString *)title
{
    return self.titleLabel.text;
}

-(void)setTextInput:(NSString *)textInput
{
    self.textInputField.text = textInput;
}

-(NSString *)textInput
{
    return self.textInputField.text;
}

-(void)setTextInputPlaceholder:(NSString *)textInputPlaceholder
{
    self.textInputField.placeholder = textInputPlaceholder;
}

-(NSString *)textInputPlaceholder
{
    return self.textInputField.placeholder;
}

-(void)setIsPassword:(BOOL)isPassword
{
    self.textInputField.secureTextEntry = isPassword;
}

-(BOOL)isPassword
{
    return self.textInputField.secureTextEntry;
}

#pragma mark -  Public

+(CGFloat)height
{
    return 70.0;
}

#pragma mark -  UITextFieldDelegate

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (!self.textInputValidationRegex) {
        return YES;
    }
    
    NSRange r = [textField.text rangeOfString:self.textInputValidationRegex options:NSRegularExpressionSearch];
    
    if (r.location == NSNotFound)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Entry Error", @"UIAlertView Title in CellWithTextInput when textInput entered doesn't validate specified regex.") message:self.textInputValidFormatMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [av show];
        
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.delegate cellWithTextInput:self textChangedTo:textField.text];
}

#pragma mark -  Private

-(void)createLabel
{
    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = [CellWithTextInput height];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.font = [AppearanceManager fontBoldWithSize:14.0];
    [self.contentView addSubview:self.titleLabel];
}

-(void)createTextField
{
    self.textInputField = [UITextField new];
    self.textInputField.delegate = self;
    self.textInputField.borderStyle = UITextBorderStyleRoundedRect;
    self.textInputField.returnKeyType = UIReturnKeyDone;
    self.textInputField.font = [AppearanceManager fontNormalWithSize:18.0];
    [self.contentView addSubview:self.textInputField];
}

-(void)adjustSubviews
{
    const CGFloat xIndentation = 16.0;
    const CGFloat yIndentation = 8.0;
        
    CGRect frame = CGRectInset(self.bounds, xIndentation, yIndentation);
    CGRect labelFrame, textFieldFrame;
    CGRectDivide(frame, &labelFrame, &textFieldFrame, 20, CGRectMinYEdge);
    
    self.titleLabel.frame = labelFrame;
    self.textInputField.frame = textFieldFrame;
}

@end

