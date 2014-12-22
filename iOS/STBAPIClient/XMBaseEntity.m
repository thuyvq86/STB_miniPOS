//
//  XBBaseEntity.m
//  iOS-XBaseSDK
//
//  Created by Patrick Lachat on 15.06.13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import "XMBaseEntity.h"


@implementation XMBaseEntity

- (id)init {
    if(self = [super init])
        self.isFromDb = NO;
    return self;
}

- (bool)isNew {
    return !self.isFromDb;
}

+ (NSMutableArray*)getAll {
    __block NSMutableArray *array = nil;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        array = [[self class] getAllInDb:db];
    }];
    return array;
}

+ (NSMutableArray*)getAllInDb:(FMDatabase*)db {
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];

    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@", [entityClass tableName]]];
    while([results next])
    {
        NSCache *aCache = [entityClass sharedCache];
        id instance = [aCache objectForKey:[NSNumber numberWithInt:[results intForColumn:@"id"]]];
        
        if(!instance) {
            instance = [entityClass instanceFromResultSet:results];
            [instance setIsFromDb:YES];
        }
        
        
        [array addObject:instance];
    }
    return array;
}


+ (id)getById:(NSInteger)anId {
    __block id instance = nil;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        instance = [[self class] getById:anId inDb:db];
    }];
    return instance;
}

+ (id)getById:(NSInteger)anId inDb:(FMDatabase*)db {
    __block bool fromCache = YES;
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    NSCache *aCache = [entityClass sharedCache];
    __block id instance = [[entityClass sharedCache] objectForKey:[NSNumber numberWithInteger:anId]];
    if(!instance) {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE id = %%d", [entityClass tableName]];
        FMResultSet *results = [db executeQueryWithFormat:queryString, anId];
        while([results next]) {
            instance = [entityClass instanceFromResultSet:results];
            [instance setIsFromDb:YES];
        }
        if(instance)
            [aCache setObject:instance forKey:[NSNumber numberWithInteger:anId]];
        fromCache = NO;
    }
    //    NSLog(@"%@ from cache: %@", [[entityClass class] description], (fromCache ? @"Yes" : @"No"));
    return instance;
}


- (bool)insertOrUpdate {
    __block bool isSuccess = NO;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        isSuccess = [self insertOrUpdateInDb:db];
    }];
    return isSuccess;
}

- (bool)save {
    return [self insertOrUpdate];
}

- (bool)insertOrUpdateInDb:(FMDatabase*)db {
    __block bool isSuccess = NO;
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    if([self isNew]) {
        NSString *queryString = [NSString stringWithFormat:@"INSERT INTO %@ %@", [entityClass tableName], [entityClass sqlFormatStringForInsert]];
        NSDictionary *parameters = [self parametersForInsertOrUpdate];
        isSuccess =[db executeUpdate:queryString withParameterDictionary:parameters];
        if(isSuccess && [self isNew]) {
            self.isFromDb = YES;
            NSInteger lastId = [db lastInsertRowId];
            self.id = lastId;
            NSCache *aCache = [entityClass sharedCache];
            [aCache setObject:self forKey:[NSNumber numberWithInteger:self.id]];
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

- (bool)delete {
    __block bool isSuccess = NO;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        isSuccess = [self deleteInDb:db];
    }];
    return isSuccess;
}

- (bool)deleteInDb:(FMDatabase*)db {
    __block bool isSuccess = ![self isNew];
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    if(![self isNew]) {
        NSString *queryString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE id = %i", [entityClass tableName], (int)self.id];
        isSuccess = [db executeUpdate:queryString];
        if(isSuccess) {
            self.isFromDb = NO;
            NSCache *aCache = [entityClass sharedCache];
            [aCache removeObjectForKey:[NSNumber numberWithInteger:self.id]];
        }
        else {
            NSError *error = [db lastError];
            NSLog(@"Last error: %@", error);
        }
    }
    return isSuccess;
}

+ (NSString*)sqlFormatStringForInsert {
    return nil; // must be overriden
}

+ (NSString*)sqlFormatStringForUpdate {
    return nil; // must be overriden
}

- (NSDictionary*)parametersForInsertOrUpdate {
    return nil; // must be overriden
}

- (NSArray*)argumentsForUpdate {
    return nil; // must be overriden
}

+ (FMDatabase*)db {
    return nil;
}

+ (FMDatabaseQueue*)dbQueue {
    return nil;
}

@end
