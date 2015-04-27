//
//  DatabaseManager.m
//  Cataracte
//
//  Created by Adrien Long on 09/04/2015.
//  Copyright (c) 2015 Adrien Long. All rights reserved.
//

#import "DatabaseManager.h"

#import <FCModel/FCModel.h>

@implementation DatabaseManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {
        
    }
    
    return self;
}

+ (instancetype)sharedInstance
{
    static DatabaseManager *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[DatabaseManager alloc] initPrivate];
    });
    
    return instance;
}

#pragma mark -  Public

-(void)configureCreationAndMigration
{
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentsPath stringByAppendingPathComponent:@"cataracteDB.sqlite3"];
#ifdef DEBUG
    NSLog(@"DB path: \n%@", dbPath);
#endif
    
    [FCModel
     openDatabaseAtPath:dbPath
     withDatabaseInitializer:nil
     schemaBuilder:^(FMDatabase *db, int *schemaVersion)
    {
        [db beginTransaction];
        
        // Custom failure handling.
        void (^failedAt)(int statement) = ^(int statement){
            int lastErrorCode = db.lastErrorCode;
            NSString *lastErrorMessage = db.lastErrorMessage;
            [db rollback];
            NSAssert3(0, @"Migration statement %d failed, code %d: %@", statement, lastErrorCode, lastErrorMessage);
        };
        
        if (*schemaVersion < 1) {
            if (! [db executeUpdate:
                   @"CREATE TABLE CATSearch ("
                   @"    id           INTEGER PRIMARY KEY,"
                   @"    query        TEXT NOT NULL DEFAULT '',"
                   @"    category     TEXT NOT NULL DEFAULT 'All',"
                   @"    subCategory  TEXT,"
                   @"    createdTime  REAL NOT NULL"
                   @");"
                   ]) failedAt(1);
            
            if (! [db executeUpdate:@"CREATE INDEX IF NOT EXISTS query ON CATSearch (query);"]) failedAt(2);
            
            if (! [db executeUpdate:
                   @"CREATE TABLE StrikeTorrent ("
                   @"    hashId       TEXT PRIMARY KEY,"
                   @"    title        TEXT NOT NULL DEFAULT '',"
                   @"    category     TEXT NOT NULL DEFAULT 'All',"
                   @"    subCategory  TEXT,"
                   @"    seeds        INTEGER NOT NULL DEFAULT 0,"
                   @"    leeches      INTEGER NOT NULL DEFAULT 0,"
                   @"    fileCount    INTEGER NOT NULL DEFAULT 0,"
                   @"    size         INTEGER NOT NULL DEFAULT 0,"
                   @"    uploadDate   REAL,"
                   @"    uploaderUsername TEXT,"
                   @"    fileNames    BLOB,"
                   @"    fileLengths  BLOB,"
                   @"    magnetUri    TEXT NOT NULL,"
                   @"    rawDescription TEXT,"
                   @"    createdTime  REAL NOT NULL,"
                   @"    bookmarked   INTEGER NOT NULL DEFAULT 0"
                   @");"
                   ]) failedAt(3);
            
            if (! [db executeUpdate:@"CREATE INDEX IF NOT EXISTS StrikeTorrentBookmarked ON StrikeTorrent (bookmarked);"]) failedAt(4);
            
            *schemaVersion = 1;
        }
        
        if ([db commit]) [self sanitizeDatabase:db];
        
    }];
}

#pragma mark - Private

-(void)sanitizeDatabase:(FMDatabase *)db
{
    [db executeUpdate:@"DELETE FROM StrikeTorrent WHERE bookmarked = 0"];
}

@end
