//
//  PairedDevice.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/22/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "PairedDevice.h"

@implementation PairedDevice

+ (FMDatabase *)db {
    return [XMDatabaseManager sharedDatabaseManager].userDataDatabase;
}

+ (FMDatabaseQueue *)dbQueue {
    return [XMDatabaseManager sharedDatabaseManager].userDataDataDatabaseQueue;
}

+ (NSString *)tableName {
    return @"PairedDevices";
}

+ (NSString*)sqlFormatStringForInsert {
    return @"(serialNumber, name, desc, lastModifiedDate) VALUES (:serialNumber, :name, :desc, :lastModifiedDate)";
}

- (NSDictionary*)parametersForInsertOrUpdate {
    NSArray *keys = [NSArray arrayWithObjects:@"serialNumber", @"name", @"desc", @"lastModifiedDate", nil];
    
    NSArray *values = [NSArray arrayWithObjects:
                       self.serialNumber,
                       self.name,
                       self.desc,
                       self.lastModifiedDate ? self.lastModifiedDate : [NSNull null],
                       nil];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

+ (NSString *)sqlFormatStringForUpdate {
    return @"name = ?, desc = ?, lastModifiedDate = ? WHERE serialNumber = ?";
}

- (NSArray*)argumentsForUpdate {
    return [NSArray arrayWithObjects:
            self.name,
            self.desc,
            self.lastModifiedDate ? self.lastModifiedDate : [NSNull null],
            self.serialNumber,
            nil];
}

+ (NSCache*)sharedCache {
    static NSCache *_shareFavoritesCache = nil;
    static dispatch_once_t once_shareFavoritesCache;
    dispatch_once(&once_shareFavoritesCache, ^{
        _shareFavoritesCache = [[NSCache alloc] init];
    });
    return _shareFavoritesCache;
}

+ (id)instanceFromResultSet:(FMResultSet*)results {
    PairedDevice *instance = [[PairedDevice alloc] init];
    instance.isFromDb = YES;
    
    instance.id = [results intForColumn:@"id"];
    instance.serialNumber = [results stringForColumn:@"serialNumber"];
    instance.name = [results stringForColumn:@"name"];
    instance.desc = [results stringForColumn:@"desc"];
    instance.lastModifiedDate = [results dateForColumn:@"lastModifiedDate"];
    
    return instance;
}

#pragma mark - Get device info

+ (id)getBySerialNumber:(NSString *)serialNumber{
    __block PairedDevice *instance = nil;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        instance = [self getBySerialNumber:serialNumber inDb:db];
    }];
    
    return instance;
}

+ (id)getBySerialNumber:(NSString *)serialNumber inDb:(FMDatabase*)db {
    __block bool fromCache = YES;
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    
    NSCache *aCache = [entityClass sharedCache];
    __block PairedDevice *instance = [[PairedDevice sharedCache] objectForKey:serialNumber];
    if(!instance) {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE serialNumber = '%@'", [entityClass tableName], serialNumber];
        FMResultSet *results = [db executeQuery:queryString];
        while([results next]) {
            instance = [entityClass instanceFromResultSet:results];
            [instance setIsFromDb:YES];
        }
        if(instance)
            [aCache setObject:instance forKey:serialNumber];
        fromCache = NO;
    }
    
    return instance;
}

//override
- (bool)insertOrUpdateInDb:(FMDatabase*)db {
    __block bool isSuccess = NO;
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    if([self isNew]) {
        NSString *queryString = [NSString stringWithFormat:@"INSERT INTO %@ %@", [entityClass tableName], [entityClass sqlFormatStringForInsert]];
        NSDictionary *parameters = [self parametersForInsertOrUpdate];
        isSuccess =[db executeUpdate:queryString withParameterDictionary:parameters];
        if(isSuccess && [self isNew]) {
            self.isFromDb = YES;
            long long lastId = [db lastInsertRowId];
            self.id = (int)lastId;
            
            NSCache *aCache = [entityClass sharedCache];
            [aCache setObject:self forKey:self.serialNumber];
        }
        else {
            NSError *error = [db lastError];
            NSLog(@"Last error: %@", error);
        }
    }
    else {
        NSString *queryString = [NSString stringWithFormat:@"UPDATE %@ SET %@", [entityClass tableName], [entityClass sqlFormatStringForUpdate]];
        NSArray *arguments = [self argumentsForUpdate];
        
        isSuccess = [db executeUpdate:queryString withArgumentsInArray:arguments];
        if(!isSuccess) {
            NSError *error = [db lastError];
            NSLog(@"Last error: %@", error);
        }
    }
    return isSuccess;
}

#pragma mark - Count

+ (NSInteger)getCount{
    __block NSInteger count = 0;
    NSString *queryString = [NSString stringWithFormat:@"select count(serialNumber) as count from %@;", [self tableName]];
    
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:queryString];
        while([results next]) {
            count = [results intForColumn:@"count"];
        }
    }];
    
    return count;
}

@end
