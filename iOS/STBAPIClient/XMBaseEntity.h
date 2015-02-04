//
//  XBBaseEntity.h
//  iOS-DBKit
//
//  Created by Nam Nguyen on 11/26/14.
//  Copyright (c) 2014 STB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMDatabaseManager.h"

@protocol XMBaseEntityProtocol <NSObject>

@required
+ (NSString*)tableName;
+ (NSCache*)sharedCache;
+ (id)instanceFromResultSet:(FMResultSet*)results;
+ (NSString*)sqlFormatStringForInsert;
+ (NSString*)sqlFormatStringForUpdate;
- (NSDictionary*)parametersForInsertOrUpdate;
- (NSArray*)argumentsForUpdate;


@end

@interface XMBaseEntity : NSObject

@property (nonatomic) bool isFromDb;
@property (nonatomic) NSInteger id;


+ (NSMutableArray*)getAll;
+ (NSMutableArray*)getAllInDb:(FMDatabase*)db;
+ (id)getById:(NSInteger)id;
+ (id)getById:(NSInteger)anId inDb:(FMDatabase*)db;
- (bool)isNew;
- (bool)insertOrUpdate;
- (bool)save;
- (bool)insertOrUpdateInDb:(FMDatabase*)db;
- (bool)delete;
- (bool)deleteInDb:(FMDatabase*)db;
+ (NSString*)sqlFormatStringForInsert;
+ (NSString*)sqlFormatStringForUpdate;
- (NSDictionary*)parametersForInsertOrUpdate;
- (NSArray*)argumentsForUpdate;
+ (FMDatabase*)db;
+ (FMDatabaseQueue*)dbQueue;

@end
