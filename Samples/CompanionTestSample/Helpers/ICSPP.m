//
//  ICSPP.m
//  iSMPTestSuite
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "ICSPP.h"

#define ICSPP_PROTOCOL_NAME @"com.ingenico.easypayemv.spm-sppchannel"

static ICSPP * g_sharedICSPPChannel = nil;


@implementation ICSPP

@synthesize streamDelegate;


+(ICSPP *)sharedChannel {
    if (g_sharedICSPPChannel == nil) {
        g_sharedICSPPChannel = [[[ICSPP alloc] init] autorelease];
    }
    return g_sharedICSPPChannel;
}


-(id)init {
    if ((self = [super initWithProtocolString:ICSPP_PROTOCOL_NAME])) {
        self.streamDelegate = nil;
    }
    return self;
}



#pragma mark NSStreamDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    switch (eventCode) {
			
		case NSStreamEventErrorOccurred: // in case of error, call super to handle it proprely
			[super stream:aStream handleEvent:eventCode];
			// fallback : also advertise the objects an error occured
			
		default:
            
            if (self.streamDelegate && [self.streamDelegate respondsToSelector:@selector(stream:handleEvent:)]) {
                [self.streamDelegate stream:aStream handleEvent:eventCode];
            }
			break;
	}
}

#pragma mark -


@end
