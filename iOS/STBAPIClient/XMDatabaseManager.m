//
//  XBDatabaseManager.m
//  iOS-XBaseSDK
//
//  Created by Lachat Patrick on 14.06.13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import "XMDatabaseManager.h"
#import "FMDatabase.h"

//#define kMasterDataDatabaseName @"xbase.sqlite"
//#define kUserDataDatabaseName @"userdata.sqlite"

@interface XMDatabaseManager()

@property (strong, nonatomic) NSString *masterDatabaseName;
@property (strong, nonatomic) NSString *backupMasterDatabaseName;
@property (strong, nonatomic) NSString *tempMasterDatabaseName;
@property (strong, nonatomic) NSString *userDatabaseName;
@property (strong, nonatomic) NSString *textResourcesDatabaseName;

@property (strong, nonatomic) NSString *masterDataDatabasePath;
@property (strong, nonatomic) NSString *backupMasterDataDatabasePath;
@property (strong, nonatomic) NSString *tempMasterDataDatabasePath;
@property (strong, nonatomic) NSString *userDataDatabasePath;
@property (strong, nonatomic) NSString *textResourcesDatabasePath;

@property (strong, nonatomic) NSString *bundlePath;
@property (strong, nonatomic) NSString *documentsPath;

@end


#pragma mark - Initialization

static NSString *kDatabasePathExtension = @"db";

@implementation XMDatabaseManager


+ (XMDatabaseManager*)sharedDatabaseManager {
    static XMDatabaseManager *_sharedDatabaseManager = nil;
    static dispatch_once_t once_sharedDatabaseManagerPredicate;
    dispatch_once(&once_sharedDatabaseManagerPredicate, ^{
        _sharedDatabaseManager = [[XMDatabaseManager alloc] init];
    });
    return _sharedDatabaseManager;
}

- (void)setupWithMasterDatabaseName:(NSString*)masterDatabaseName userDatabaseName:(NSString*)userDatabaseName textResourcesDatabaseName:(NSString*)textResourcesDatabaseName {
    NSString *documentsDir = [XMDatabaseManager applicationDocumentsDirectory];
    
//    self.masterDatabaseName = [masterDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
//    self.backupMasterDatabaseName = [[NSString stringWithFormat:@"backup_%@", masterDatabaseName] stringByAppendingPathExtension:kDatabasePathExtension];
//    self.tempMasterDatabaseName = [[NSString stringWithFormat:@"temp_%@", masterDatabaseName] stringByAppendingPathExtension:kDatabasePathExtension];
    self.userDatabaseName = [userDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
//    self.textResourcesDatabaseName = [textResourcesDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
//    
//    self.masterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.masterDatabaseName];
//    self.backupMasterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.backupMasterDatabaseName];
//    self.tempMasterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.tempMasterDatabaseName];

    self.userDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.userDatabaseName];
//    self.textResourcesDatabasePath = [documentsDir stringByAppendingPathComponent:self.textResourcesDatabaseName];
    
//    [self createAndCheckDatabaseFromPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.masterDatabaseName] toPath:self.masterDataDatabasePath removeExisting:NO];
    [self createAndCheckDatabaseFromPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.userDatabaseName] toPath:self.userDataDatabasePath removeExisting:NO];
//    [self createAndCheckDatabaseFromPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.textResourcesDatabaseName] toPath:self.textResourcesDatabasePath removeExisting:NO];
}

- (void)setupForUnitTestsWithMasterDatabaseName:(NSString*)masterDatabaseName userDatabaseName:(NSString*)userDatabaseName textResourcesDatabaseName:(NSString*)textResourcesDatabaseName {
    NSString *documentsDir = [XMDatabaseManager unitTestsDocumentsDirectory];
    
    self.masterDatabaseName = [masterDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
    self.backupMasterDatabaseName = [[NSString stringWithFormat:@"backup_%@", masterDatabaseName] stringByAppendingPathExtension:kDatabasePathExtension];
    self.tempMasterDatabaseName = [[NSString stringWithFormat:@"temp_%@", masterDatabaseName] stringByAppendingPathExtension:kDatabasePathExtension];
    self.userDatabaseName = [userDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
    self.textResourcesDatabaseName = [textResourcesDatabaseName stringByAppendingPathExtension:kDatabasePathExtension];
    
    self.masterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.masterDatabaseName];
    self.backupMasterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.backupMasterDatabaseName];
    self.tempMasterDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.tempMasterDatabaseName];
    self.userDataDatabasePath = [documentsDir stringByAppendingPathComponent:self.userDatabaseName];
    self.textResourcesDatabasePath = [documentsDir stringByAppendingPathComponent:self.textResourcesDatabaseName];
    
    [self createAndCheckDatabaseFromPath:[[NSBundle bundleForClass:[self class]] pathForResource:masterDatabaseName ofType:kDatabasePathExtension] toPath:self.masterDataDatabasePath removeExisting:YES];

    [self createAndCheckDatabaseFromPath:[[NSBundle bundleForClass:[self class]] pathForResource:userDatabaseName ofType:kDatabasePathExtension] toPath:self.userDataDatabasePath removeExisting:YES];
    [self createAndCheckDatabaseFromPath:[[NSBundle bundleForClass:[self class]] pathForResource:textResourcesDatabaseName ofType:kDatabasePathExtension] toPath:self.textResourcesDatabasePath removeExisting:YES];
    
}

- (BOOL)createAndCheckDatabaseFromPath:(NSString*)fromPath toPath:(NSString*)toPath removeExisting:(BOOL)removeExisting {
    BOOL success = NO;
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(removeExisting && [fileManager fileExistsAtPath:toPath]) {
        // force replacement
        [fileManager removeItemAtPath:toPath error:&error];
        success = [fileManager fileExistsAtPath:toPath];
        
        if(!success)
        {
            if([fileManager fileExistsAtPath:fromPath]) {
                NSError *error = nil;
                success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
            }
        }
    }
    else {
        // check if update required, if so, replace db
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSString *storedKey = [NSString stringWithFormat:@"user_version_%@", [[toPath lastPathComponent] stringByDeletingPathExtension]];
        
        NSInteger currrentVersion = [defaults integerForKey:storedKey];
        
        // get new version
        NSInteger newVersion = [self detectNewVersion:fromPath];
        
        //DLog(@"storedKey: %@ currrentVersion: %i newVersion: %i", storedKey, currrentVersion, newVersion);
        
        if(newVersion > currrentVersion) {
            // there's a newer version
            
            if([fileManager fileExistsAtPath:toPath]) {
                // remove old version
                [fileManager removeItemAtPath:toPath error:&error];
            }
            
            // make sure we've removed the old version
            success = [fileManager fileExistsAtPath:toPath];
            
            if(!success)
            {
                // make sure there is a db at the from location, and copy it
                if([fileManager fileExistsAtPath:fromPath]) {
                    NSError *error = nil;
                    success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
                    if(success) {
                        [defaults setInteger:newVersion forKey:storedKey];
                        [defaults synchronize];
                    }
                }
            }
        }
    }
    return success;
}

- (NSInteger)detectNewVersion:(NSString*)fromPath {
    NSInteger newVersion = 0;
    FMDatabase *tmpDatabase = [[FMDatabase alloc] initWithPath:fromPath];
    [tmpDatabase open];
    FMResultSet *resultSet = [tmpDatabase executeQuery:@"PRAGMA user_version"];
    while ([resultSet next]) {
        newVersion = [resultSet intForColumnIndex:0];
        break;
    }
    [tmpDatabase close];
    return newVersion;
}

- (FMDatabase*)masterDataDatabase {
    return [[FMDatabase alloc] initWithPath:self.masterDataDatabasePath];
}

- (FMDatabase*)tempMasterDataDatabase {
    return [[FMDatabase alloc] initWithPath:self.tempMasterDataDatabasePath];
}

- (FMDatabase*)userDataDatabase {
    return [[FMDatabase alloc] initWithPath:self.userDataDatabasePath];
}

- (FMDatabase*)textResourcesDatabase {
    return [[FMDatabase alloc] initWithPath:self.textResourcesDatabasePath];
}

- (FMDatabaseQueue*)masterDataDatabaseQueue {
    return [FMDatabaseQueue databaseQueueWithPath:self.masterDataDatabasePath];
}

- (FMDatabaseQueue*)tempMasterDataDatabaseQueue {
    return [FMDatabaseQueue databaseQueueWithPath:self.tempMasterDataDatabasePath];
}

- (FMDatabaseQueue*)userDataDataDatabaseQueue {
    return [FMDatabaseQueue databaseQueueWithPath:self.userDataDatabasePath];
}

- (FMDatabaseQueue*)textResourcesDatabaseQueue {
    return [FMDatabaseQueue databaseQueueWithPath:self.textResourcesDatabasePath];
}

- (BOOL)createNewTempMasterDataDatabase {
    BOOL success = YES;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:self.tempMasterDataDatabasePath]) {
        NSError *error = nil;
        if(![fileManager removeItemAtPath:self.tempMasterDataDatabasePath error:&error]) {
            success = NO;
        }
    }
    
    if(success) {
        FMDatabase *database = [FMDatabase databaseWithPath:self.tempMasterDataDatabasePath];
        
        if(database) {
            NSArray *statements = [self getCreateStatements];
            
            [[self tempMasterDataDatabaseQueue] inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [statements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSString *statement = (NSString*)obj;
                    [db executeUpdate:statement];
                }];
            }];
        }
    }
    return success;
}

- (BOOL)replaceMasterDataDatabaseWithNewTempMasterDataDatabase {
    BOOL success = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    
    //[self.masterDataDatabase close];

    if([fileManager fileExistsAtPath:self.masterDataDatabasePath]) {
        if([fileManager fileExistsAtPath:self.tempMasterDataDatabasePath]) {
            if([fileManager moveItemAtPath:self.masterDataDatabasePath toPath:self.backupMasterDataDatabasePath error:&error]) {
                if([fileManager moveItemAtPath:self.tempMasterDataDatabasePath toPath:self.masterDataDatabasePath error:&error]) {
                    success = [fileManager removeItemAtPath:self.backupMasterDataDatabasePath error:&error];
                }
            }
        }
    }
    
    if(error)
        NSLog(@"ERROR: %@", error);
    
    return success;
}

- (NSArray*)getCreateStatements {
    NSMutableArray *statements = [NSMutableArray array];
    [self.masterDataDatabaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:@"select sql from SQLITE_MASTER where sql not null order by rootpage"];
        
        while ([results next]) {
            [statements addObject:[results stringForColumn:@"sql"]];
        }
    }];
    
    return statements;
}



+ (NSString*)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

+ (NSString*)unitTestsDocumentsDirectory {
    return NSTemporaryDirectory();
}

@end
