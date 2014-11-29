//
//  CrashReporterManager.m
//  IAPTunnelUK
//
//  Created by Hichem Boussetta on 16/05/12.
//  Copyright (c) 2012 Theoris. All rights reserved.
//

#import "CrashReporterManager.h"

#import <asl.h>

static CrashReporterManager * g_sharedCrashReporterManager = nil;

#define kDefaultCrashReportingServerURL     @"https://integration.services.ingenico.com:25358/bugreport.php"


@interface CrashReporterManager ()

@property (nonatomic, retain) NSData            * crashFileData;
@property (nonatomic, retain) NSURLConnection   * crashLogUploadUrlConnection;
@property (nonatomic, retain) NSURLConnection   * appLogUploadUrlConnection;

-(void)uploadCrashReportToServer;
-(void)checkForCrashReports;
-(void)applicationDidFinishLaunching;
-(void)uploadApplicationLogsToServer;

@end


@implementation CrashReporterManager
@synthesize crashFileData;
@synthesize crashReportingServerURL;
@synthesize crashLogUploadUrlConnection;
@synthesize appLogUploadUrlConnection;


+(CrashReporterManager *)sharedCrashReporterManager {
    if (g_sharedCrashReporterManager == nil) {
        g_sharedCrashReporterManager = [[CrashReporterManager alloc] init];
    }
    return g_sharedCrashReporterManager;
}

-(id)init {
    if ((self = [super init])) {
        //Variable Intialization
        self.crashFileData = nil;
        self.crashReportingServerURL = kDefaultCrashReportingServerURL;
        
        //Subscribe for application launch notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunching) name:UIApplicationDidFinishLaunchingNotification object:nil];
        
        //Check for existant crash reports and upload them to the default server - then enable crash reporting
        [self checkForCrashReports];
    }
    return self;
}

-(oneway void)release {
    
}

-(void)applicationDidFinishLaunching {
    NSLog(@"%s", __FUNCTION__);
}


-(void)checkForCrashReports {
    NSLog(@"%s", __FUNCTION__);
    
    PLCrashReporter * crashReporter = [PLCrashReporter sharedReporter];
    
    //Check if there is a pending crash log file
    if ([crashReporter hasPendingCrashReport]) {
        NSLog(@"%s Application has pending crash reports", __FUNCTION__);
        NSError * crashReportLoadError = nil;
        
        //Get the crash data and upload it to the remote server
        self.crashFileData = [crashReporter loadPendingCrashReportDataAndReturnError:&crashReportLoadError];
        if (self.crashFileData == nil) {
            NSLog(@"%s Failed to load crash log data [Error description: %@]", __FUNCTION__, [crashReportLoadError description]);
        } else if ([self.crashFileData length] > 0) {
            
            //Upload the crash reports
            [self uploadCrashReportToServer];
        } else {
            NSLog(@"%s Empty crash report --> Won't be uploaded to server", __FUNCTION__);
        }
        
        //Upload application logs to the remote server
        [self uploadApplicationLogsToServer];
    } else {
        NSLog(@"%s Crash Reporter does not have any report to upload", __FUNCTION__);
    }
    
    //Enable crash reporting
    NSError * crashReportingActivationError = nil;
    if ([crashReporter enableCrashReporterAndReturnError:&crashReportingActivationError] == NO) {
        NSLog(@"%s Could not enable crash reporter [Error description: %@]", __FUNCTION__, [crashReportingActivationError description]);
    } else {
        NSLog(@"%s Crash Reporting Service Started", __FUNCTION__);
    }
}

-(void)uploadCrashReportToServer {
    NSLog(@"%s", __FUNCTION__);
    
    //Format the binary report
    PLCrashReport * crashReport = [[PLCrashReport alloc] initWithData:self.crashFileData error:nil];
    NSString * formattedCrashReport = [PLCrashReportTextFormatter stringValueForCrashReport:crashReport
                                                                             withTextFormat: PLCrashReportTextFormatiOS];
    [crashReport release];
    
    NSString *urlString = self.crashReportingServerURL;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd.HH.mm.ss"];
    NSString *filename = [NSString stringWithFormat:@"crashlog.%@.%@", [dateFormatter stringFromDate:[NSDate date]], [[UIDevice currentDevice] name]];
    [dateFormatter release];
    
    //NSLog(@"%s Bug Report: \n\r%@", __FUNCTION__, formattedCrashReport);
    
    NSMutableURLRequest * request= [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"crashfile\"; filename=\"%@.log\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"%@",@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[NSData dataWithBytes:[formattedCrashReport UTF8String] length:[formattedCrashReport lengthOfBytesUsingEncoding:NSUTF8StringEncoding]]];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
    
    
    //NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    self.crashLogUploadUrlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    if (!self.crashLogUploadUrlConnection) {
        NSLog(@"%s Failed to open connection to the bug-reporting server", __FUNCTION__);
    }
}



#pragma mark NSURLConnectionDataDelegate

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    NSLog(@"%s", __FUNCTION__);
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {  
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"Trust Challange");
    SecTrustResultType trustResultType;
    OSStatus err=SecTrustEvaluate(challenge.protectionSpace.serverTrust, &trustResultType);
    
    NSLog(@"SecTrustResult %lu %ld",trustResultType,err);
    
    if (trustResultType == kSecTrustResultProceed || trustResultType == kSecTrustResultConfirm || trustResultType == kSecTrustResultUnspecified || trustResultType == kSecTrustResultRecoverableTrustFailure) {
        NSLog(@"%s Trust the server", __FUNCTION__);
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    else{
        NSLog(@"%s Cancel the authentication challenge", __FUNCTION__);
        [challenge.sender cancelAuthenticationChallenge:challenge];
    }
    
    //[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"%s", __FUNCTION__); 
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"%s", __FUNCTION__);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%s", __FUNCTION__);
    
    if (connection == self.crashLogUploadUrlConnection) {
        NSLog(@"%s  Crash report uploaded to server", __FUNCTION__);
        
        //Purge crash log data
        NSError * crashReporterPurgeError = nil;
        if ([[PLCrashReporter sharedReporter] purgePendingCrashReportAndReturnError:&crashReporterPurgeError] == NO) {
            NSLog(@"%s Failed to purge crash logs [Error description: %@]", __FUNCTION__, [crashReporterPurgeError description]);
        }
    } else if (connection == self.appLogUploadUrlConnection) {
        NSLog(@"%s Application Logs uploaded to server", __FUNCTION__);
    } else {
        NSLog(@"%s Some unknown connection failed", __FUNCTION__);
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    
    if (connection == self.crashLogUploadUrlConnection) {
        NSLog(@"%s Failed to upload crash reports [Description: %@, Reason: %@, Recovery: %@]", __FUNCTION__, [error localizedDescription], [error localizedFailureReason], [error localizedRecoverySuggestion]);
    } else if (connection == self.appLogUploadUrlConnection) {
        NSLog(@"%s Failed to upload application logs [Description: %@, Reason: %@, Recovery: %@]", __FUNCTION__, [error localizedDescription], [error localizedFailureReason], [error localizedRecoverySuggestion]);
    }
}

#pragma mark -


#pragma mark Access Apple System Log

-(NSString *)getApplicationLogs {
    NSLog(@"%s", __FUNCTION__);
    
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
                long logTimeStamp = [string longLongValue];
                char * logTime = ctime(&logTimeStamp);
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
    
    //NSLog(@"%s %@", __FUNCTION__, appLogs);
    
    return appLogs;
}


-(void)uploadApplicationLogsToServer {
    NSLog(@"%s", __FUNCTION__);
    
    NSString *urlString = self.crashReportingServerURL;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy.MM.dd.HH.mm.ss"];
    NSString *filename = [NSString stringWithFormat:@"appLogs.%@.%@.txt", [dateFormatter stringFromDate:[NSDate date]], [[UIDevice currentDevice] name]];
    [dateFormatter release];
    
    //Get the app logs
    NSString * logs = [self getApplicationLogs];
    NSData * logsFileData = [NSData dataWithBytes:[logs UTF8String] length:[logs length]];
    
    //Build the request
    NSMutableURLRequest * request= [[[NSMutableURLRequest alloc] init] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *postbody = [NSMutableData data];
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"logfile\"; filename=\"%@.log\"\r\n", filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [postbody appendData:[[NSString stringWithFormat:@"%@",@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    if (logsFileData) {
        [postbody appendData:logsFileData];
    }
    [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postbody];
        
    self.appLogUploadUrlConnection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    if (!self.appLogUploadUrlConnection) {
        NSLog(@"%s Failed to open connection to the bug-reporting server", __FUNCTION__);
    }
}

#pragma mark -


@end
