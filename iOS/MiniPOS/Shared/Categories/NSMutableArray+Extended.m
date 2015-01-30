//
//  NSMutableArray+Extended.m
//  Anibis
//
//  Created by Nam Nguyen on 11/18/13.
//  Copyright (c) 2013 Xmedia AG. All rights reserved.
//

#import "NSMutableArray+Extended.h"

@implementation NSMutableArray (Extended)

//Refs: http://www.icab.de/blog/2009/11/15/moving-objects-within-an-nsmutablearray/
- (void)moveObjectAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex{
    if (fromIndex == toIndex) return;
    if (fromIndex < 0 || fromIndex >= self.count) return; //there is no object to move, return
    if (toIndex > self.count - 1) toIndex = self.count - 1; //toIndex too large, assume a move to end
    id movingObject = [self objectAtIndex:fromIndex];
    
    if (fromIndex < toIndex){
        for (NSInteger i = fromIndex; i <= toIndex; i++){
            [self replaceObjectAtIndex:i withObject:(i == toIndex) ? movingObject : [self objectAtIndex:i + 1]];
        }
    } else {
        id cObject;
        id prevObject;
        for (NSInteger i = toIndex; i <= fromIndex; i++){
            cObject = [self objectAtIndex:i];
            [self replaceObjectAtIndex:i withObject:(i == toIndex) ? movingObject : prevObject];
            prevObject = cObject;
        }
    }
}

//get index of object
+ (NSUInteger)indexOfObjectById:(NSInteger)objectId inArray:(NSArray *)array
{
    if (nil == array || [array count] == 0) {
        return -1; //not found
    }
    
    return [array indexOfObjectPassingTest:
            ^BOOL(id object, NSUInteger idx, BOOL *stop) {
                NSInteger compareId = [[object valueForKey:@"id"] integerValue];
                if (compareId == objectId) {
                    *stop = YES;
                    return YES;
                }
                return NO; //not found
            }];
}

@end
