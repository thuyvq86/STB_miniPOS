//
//  GateWayManager.h
//  InteractivePayment
//
//  Created by Hichem Boussetta on 07/12/11.
//  Copyright (c) 2011 Theoris. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GateWayManager : NSObject <ICISMPDeviceDelegate, ICNetworkDelegate>

+(GateWayManager *)sharedGateWayManager;


//Start or Stop the GatewayManager - These will open/close the network communication channel
-(void)start;
-(void)stop;

@end
