//
//  DatabaseManager.h
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseManager : NSObject

+(instancetype)sharedInstance;

-(void)configureCreationAndMigration;

@end
