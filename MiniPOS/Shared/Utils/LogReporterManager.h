//
//  CrashReporterManager.h
//  IAPTunnelUK
//
//  Created by Hichem Boussetta on 16/05/12.
//  Copyright (c) 2012 Theoris. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MessageUI/MessageUI.h>

@interface LogReporterManager : NSObject <NSURLConnectionDataDelegate, MFMailComposeViewControllerDelegate>

+(LogReporterManager *)sharedCrashReporterManager;

@end
