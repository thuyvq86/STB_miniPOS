//
//  CrashReporterManager.h
//  IAPTunnelUK
//
//  Created by Hichem Boussetta on 16/05/12.
//  Copyright (c) 2012 Theoris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashReporterManager : NSObject <NSURLConnectionDataDelegate>

+(CrashReporterManager *)sharedCrashReporterManager;

@property (nonatomic, retain) NSString * crashReportingServerURL;

-(NSString *)getApplicationLogs;

@end
