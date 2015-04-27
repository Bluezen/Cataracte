//
//  CellWithTextInput.h
//  Cataracte
//
//  Created by Adrien Long on 23/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+Utilities.h"

@protocol CellWithTextInputDelegate;

@interface CellWithTextInput : UITableViewCell

@property(nonatomic, weak) id <CellWithTextInputDelegate> delegate;

@property(nonatomic, strong) NSString *title;
@property(nonatomic, strong) NSString *textInput;
@property(nonatomic, strong) NSString *textInputPlaceholder;


+(CGFloat)height;

@property(nonatomic, strong) NSString *textInputValidationRegex;
@property(nonatomic, strong) NSString *textInputValidFormatMessage;

@property(nonatomic, assign) BOOL isPassword;

@end

@protocol CellWithTextInputDelegate <NSObject>
-(void)cellWithTextInput:(CellWithTextInput *)cell textChangedTo:(NSString *)newTextInput;
@end
