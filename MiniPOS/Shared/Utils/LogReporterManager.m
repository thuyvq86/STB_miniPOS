//
//  CrashReporterManager.m
//  IAPTunnelUK
//
//  Created by Hichem Boussetta on 16/05/12.
//  Copyright (c) 2012 Theoris. All rights reserved.
//

#import "LogReporterManager.h"
#import <asl.h>

@interface LogReporterManager ()

- (NSString *)getApplicationLogs;

@property(nonatomic, assign) UIViewController *viewController;

@end

@implementation LogReporterManager

@synthesize viewController;

+ (LogReporterManager*)sharedCrashReporterManager {
    static LogReporterManager *_sharedManager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init {
    if ((self = [super init])) {
        
    }
    return self;
}

#pragma mark - Access Apple System Log

- (NSString *)getApplicationLogs {
    DLog();
    
    aslmsg q, m;
    int i;
    const char *key, *val;
    NSMutableString * appLogs = [NSMutableString string];
    
    q = asl_new(ASL_TYPE_QUERY);
    
    //Filter the application Logs
    NSString * appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    asl_set_query(q, ASL_KEY_SENDER, [appName UTF8String], ASL_QUERY_OP_EQUAL);
    
    aslresponse r = asl_search(NULL, q);
    while (NULL != (m = aslresponse_next(r)))
    {
        NSString * logMessage   = nil;
        NSString * timeStamp    = nil;
        
        for (i = 0; (NULL != (key = asl_key(m, i))); i++)
        {
            NSString *keyString = [NSString stringWithUTF8String:(char *)key];
            
            val = asl_get(m, key);
            
            NSString *string = [NSString stringWithUTF8String:val];
            
            if ([keyString isEqualToString:[NSString stringWithFormat:@"%s", ASL_KEY_TIME]]) {
                
                //Get the time
                long logTimeStamp = [string doubleValue];
                char *logTime = ctime(&logTimeStamp);
                logTime[strlen(logTime) - 1] = '\0';    //Remove the trailing new line character
                
                timeStamp = [NSString stringWithFormat:@"%s", logTime];
            } else if ([keyString isEqualToString:[NSString stringWithFormat:@"%s", ASL_KEY_MSG]]) {
                logMessage = string;
            }
        }
        
        //Append log statement to the appLogs string
        [appLogs appendFormat:@"[%@]%@\n", timeStamp, logMessage];
    }
    aslresponse_free(r);
    
    //DLog(@"%s", appLogs);
    
    return appLogs;
}

@end
