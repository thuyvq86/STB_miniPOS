//
//  XBDatabaseManager.h
//  iOS-DBKit
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface XMDatabaseManager : NSObject

+ (XMDatabaseManager*)sharedDatabaseManager;
+ (NSString*)applicationDocumentsDirectory;

- (void)setupWithMasterDatabaseName:(NSString*)masterDatabaseName userDatabaseName:(NSString*)userDatabaseName textResourcesDatabaseName:(NSString*)textResourcesDatabaseName;
- (void)setupForUnitTestsWithMasterDatabaseName:(NSString*)masterDatabaseName userDatabaseName:(NSString*)userDatabaseName textResourcesDatabaseName:(NSString*)textResourcesDatabaseName;

- (FMDatabase*)tempMasterDataDatabase;
- (FMDatabase*)masterDataDatabase;
- (FMDatabase*)userDataDatabase;
- (FMDatabase*)textResourcesDatabase;

- (FMDatabaseQueue*)tempMasterDataDatabaseQueue;
- (FMDatabaseQueue*)masterDataDatabaseQueue;
- (FMDatabaseQueue*)userDataDataDatabaseQueue;
- (FMDatabaseQueue*)textResourcesDatabaseQueue;

- (BOOL)createNewTempMasterDataDatabase;
- (BOOL)replaceMasterDataDatabaseWithNewTempMasterDataDatabase;

@end