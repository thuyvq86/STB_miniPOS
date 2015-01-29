//
//  ICSPP.h
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ICSPP : ICISMPDevice

@property (nonatomic, retain) id<NSStreamDelegate>  streamDelegate;

+(ICSPP *)sharedChannel;

@end
