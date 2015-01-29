//
//  TestCategoryManager.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 28/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TestCategoryManager : NSObject {
	
	NSString			* testGroup;
	NSMutableArray		* categories;
	NSMutableArray		* _testList;
}

@property (nonatomic, copy) NSString * testGroup;
@property (nonatomic, readonly) NSArray * categories;

-(id)initWithBaseGroupName:(NSString *)name;

-(NSArray *)testListForCategory:(NSString *)category;


@end
