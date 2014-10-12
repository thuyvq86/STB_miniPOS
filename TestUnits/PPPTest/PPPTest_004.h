//
//  PPPTest_004.h
//  iSMPTestSuite
//
//  Created by Hichem BOUSSETTA on 14/06/13.
//  Copyright (c) 2013 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BasicPPPTest.h"
#import <iSMP-Private/ICTcpServer.h>

@interface PPPTest_004 : BasicPPPTest <NSStreamDelegate, ICTcpServerDelegate>

@property (nonatomic, retain) UISwitch              * switchPPP;
@property (nonatomic, retain) UITextField           * textWlanIP;
@property (nonatomic, retain) UITextField           * textIP;
@property (nonatomic, retain) UITextField           * textMessage;
@property (nonatomic, retain) UIButton              * buttonSend;
@property (nonatomic, retain) UISegmentedControl    * segServers;

@property (nonatomic, retain) NSMutableArray        * textPorts;
@property (nonatomic, retain) NSMutableArray        * tcpServers;

-(void)onSwitchPPPValueChanged;

-(void)onButtonSendMessagePressed;

-(void)startTcpServers;
-(void)stopTcpServers;

-(NSInteger)getIndexOfServer:(ICTcpServer *)server;
-(NSInteger)getIndexOfServerWithOutStream:(NSOutputStream *)stream;
-(NSInteger)getIndexOfServerWithInStream:(NSInputStream *)stream;

@end
