//
//  PPPTest_002.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"

#import <iSMP/ICTcpServer.h>

@interface PPPTest_002 : BasicPPPTest <NSStreamDelegate, ICTcpServerDelegate>

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;
@property (nonatomic, retain) UITextField           * textPortForInternalConnections;
@property (nonatomic, retain) UITextField           * textMessage;
@property (nonatomic, retain) UIButton              * buttonSend;

@property (nonatomic, retain) ICTcpServer           * tcpServer;

-(void)onSwitchPPPValueChanged;

-(void)onButtonSendMessagePressed;

-(void)startTcpServer;
-(void)stopTcpServer;

@end
