//
//  NSMutableArray+Extended.h
//  Anibis
//
//  Created by Nam Nguyen on 11/18/13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Extended)

//Moving objects
- (void)moveObjectAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

//get index of object
+ (NSUInteger)indexOfObjectById:(NSInteger)objectId inArray:(NSArray *)array;

@end
