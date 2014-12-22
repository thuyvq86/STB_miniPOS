//
//  XBDatabaseManager.h
//  iOS-XMKit
//
//  Created by Lachat Patrick on 14.06.13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
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