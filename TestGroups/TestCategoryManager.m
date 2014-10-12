//
//  TestCategoryManager.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 28/12/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import "TestCategoryManager.h"
#import "BasicTest.h"

@implementation TestCategoryManager
@synthesize testGroup, categories;


-(id)initWithBaseGroupName:(NSString *)name {
	if ((self = [super init])) {
		categories = [[NSMutableArray alloc] init];
		_testList = [[NSMutableArray alloc] init];

		for (int i = 1; i < 1000; i++) {
			NSString * testClassName = [NSString stringWithFormat:@"%@_%03d", name, i];
			Class class = NSClassFromString(testClassName);
			
			if (class != nil) {
				NSString * category = [class category];
				if (category != nil) {
					if ([categories containsObject:category] == NO) {
						[categories addObject:[NSString stringWithString:category]];
					}
				}
				[_testList addObject:testClassName];
			} else {
				break;
			}
		}
		if ([categories count] == 0) {
			//Add an empty category
			[categories addObject:@""];
		}
	}
	return self;
}

-(void)dealloc {
	[categories release];
	[_testList release];
	[super dealloc];
}


-(NSArray *)testListForCategory:(NSString *)category {
	if ((category == nil) || ([category isEqualToString:@""])) {
		return _testList;
	}
	NSMutableArray * testList = [[[NSMutableArray alloc] init] autorelease];
	for (NSString * testClassName in _testList) {
		Class class = NSClassFromString(testClassName);
		if ([[class category] isEqualToString:category] == YES) {
			[testList addObject:testClassName];
		}
	}
	return testList;
}


@end
