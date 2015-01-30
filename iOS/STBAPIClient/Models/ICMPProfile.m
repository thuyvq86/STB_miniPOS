//
//  PairedDevice.m
//  MiniPOS
//
//  Created by Nam Nguyen on 12/22/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import "ICMPProfile.h"

@implementation ICMPProfile

#pragma mark - 

- (NSString *)displayableName{
    NSString *name = nil;
    
    name = [NSString stringWithFormat:@"%@ - %@",
            self.merchantName,
            self.serialId
            ];
    
    return name;
}

- (NSString *)descriptionOfProfile{
    NSString *desc = nil;
    
    desc = [NSString stringWithFormat:
            @"Merchant Id: %@\nMerchant name: %@\nPhone serial Id: %@\nTerminal Id: %@",
            self.merchantId,
            self.merchantName,
            self.phoneSerialId,
            self.terminalId
            ];
    
    return desc;
}

- (id)initWithICISMPDevice{
    self = [super init];
    if (self) {
        self.serialId = [ICISMPDevice serialNumber];
        self.merchantName = @"Unknown merchant";
    }
    
    return self;
}

- (BOOL)updateFromDictionary:(NSDictionary *)dict{
    __block BOOL success = NO;
    __block ICMPProfile *instance = self;
    
    instance.merchantId = [[dict objectForKey:@"MerchantID"] stringByRemovingNewLinesAndWhitespace];
    instance.merchantName = [[dict objectForKey:@"MerchantName"] stringByRemovingNewLinesAndWhitespace];
    instance.phoneSerialId = [[dict objectForKey:@"PhoneSerialID"] stringByRemovingNewLinesAndWhitespace];
    instance.terminalId = [[dict objectForKey:@"TerminalID"] stringByRemovingNewLinesAndWhitespace];
    
    [[ICMPProfile dbQueue] inDatabase:^(FMDatabase *db) {
        success = [instance insertOrUpdateInDb:db];
        if (success)
            [[ICMPProfile sharedCache] setObject:self forKey:instance.serialId];
    }];
    
    return success;
}

- (BOOL)resetProfile{
    __block BOOL success = NO;
    __block ICMPProfile *instance = self;
    
    instance.merchantId = nil;
    instance.merchantName = @"Unknown merchant";
    instance.phoneSerialId = nil;
    instance.terminalId = nil;
    
    [[ICMPProfile dbQueue] inDatabase:^(FMDatabase *db) {
        success = [instance insertOrUpdateInDb:db];
        if (success)
            [[ICMPProfile sharedCache] setObject:self forKey:instance.serialId];
    }];
    
    return success;
}

#pragma mark - db

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
    return @"(serialId, merchantId, merchantName, phoneSerialId, terminalId, lastModifiedDate) VALUES (:serialId, :merchantId, :merchantName, :phoneSerialId, :terminalId, :lastModifiedDate)";
}

- (NSDictionary*)parametersForInsertOrUpdate {
    NSArray *keys = [NSArray arrayWithObjects:@"serialId", @"merchantId", @"merchantName", @"phoneSerialId", @"terminalId", @"lastModifiedDate", nil];
    
    NSArray *values = [NSArray arrayWithObjects:
                       self.serialId,
                       self.merchantId ? self.merchantId : @"",
                       self.merchantName ? self.merchantName : @"",
                       self.phoneSerialId ? self.phoneSerialId : @"",
                       self.terminalId ? self.terminalId : @"",
                       self.lastModifiedDate ? self.lastModifiedDate : [NSNull null],
                       nil];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

+ (NSString *)sqlFormatStringForUpdate {
    return @"merchantId = ?, merchantName = ?, phoneSerialId = ?, terminalId = ?, lastModifiedDate = ? WHERE serialId = ?";
}

- (NSArray*)argumentsForUpdate {
    return [NSArray arrayWithObjects:
            self.merchantId ? self.merchantId : @"",
            self.merchantName ? self.merchantName : @"",
            self.phoneSerialId ? self.phoneSerialId : @"",
            self.terminalId ? self.terminalId : @"",
            self.lastModifiedDate ? self.lastModifiedDate : [NSNull null],
            self.serialId,
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
    ICMPProfile *instance = [[ICMPProfile alloc] init];
    instance.isFromDb = YES;
    
    instance.id = [results intForColumn:@"id"];
    instance.serialId = [results stringForColumn:@"serialId"];
    instance.merchantId = [results stringForColumn:@"merchantId"];
    instance.merchantName = [results stringForColumn:@"merchantName"];
    instance.phoneSerialId = [results stringForColumn:@"phoneSerialId"];
    instance.terminalId = [results stringForColumn:@"terminalId"];
    instance.lastModifiedDate = [results dateForColumn:@"lastModifiedDate"];
    
    return instance;
}

- (void)updateFromResultSet:(FMResultSet*)results {
    self.merchantId = [results stringForColumn:@"merchantId"];
    self.merchantName = [results stringForColumn:@"merchantName"];
    self.phoneSerialId = [results stringForColumn:@"phoneSerialId"];
    self.terminalId = [results stringForColumn:@"terminalId"];
}

#pragma mark - Get device info

+ (id)getBySerialNumber:(NSString *)serialNumber{
    __block ICMPProfile *instance = nil;
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        instance = [self getBySerialNumber:serialNumber inDb:db];
    }];
    
    return instance;
}

+ (id)getBySerialNumber:(NSString *)serialNumber inDb:(FMDatabase*)db {
    __block bool fromCache = YES;
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    
    NSCache *aCache = [entityClass sharedCache];
    __block ICMPProfile *instance = [[ICMPProfile sharedCache] objectForKey:serialNumber];
    if(!instance) {
        NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE serialId = '%@'", [entityClass tableName], serialNumber];
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
+ (NSMutableArray*)getAllInDb:(FMDatabase*)db{
    __block NSMutableArray *array = [[NSMutableArray alloc] init];
    id <XMBaseEntityProtocol> entityClass = (id <XMBaseEntityProtocol>) [self class];
    
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ ORDER BY lastModifiedDate DESC", [entityClass tableName]]];
    while([results next])
    {
        NSCache *aCache = [entityClass sharedCache];
        id instance = [aCache objectForKey:[results stringForColumn:@"serialId"]];
        
        if(!instance) {
            instance = [entityClass instanceFromResultSet:results];
            [instance setIsFromDb:YES];
        }
        else{
            [instance updateFromResultSet:results];
        }
        
        [array addObject:instance];
    }
    return array;
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
            long long lastId = [db lastInsertRowId];
            self.id = (int)lastId;
            
            NSCache *aCache = [entityClass sharedCache];
            [aCache setObject:self forKey:self.serialId];
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
    NSString *queryString = [NSString stringWithFormat:@"select count(serialId) as count from %@;", [self tableName]];
    
    [[[self class] dbQueue] inDatabase:^(FMDatabase *db) {
        FMResultSet *results = [db executeQuery:queryString];
        while([results next]) {
            count = [results intForColumn:@"count"];
        }
    }];
    
    return count;
}

@end
