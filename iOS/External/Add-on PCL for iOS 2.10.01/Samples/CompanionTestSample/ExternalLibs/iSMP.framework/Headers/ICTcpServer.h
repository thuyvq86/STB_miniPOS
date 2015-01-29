//
//  ICTcpServer.h
//  PCL
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ICTcpServerDelegate;

@interface ICTcpServer : NSObject <NSStreamDelegate> {

    CFSocketRef ipsocket;                                                       /**< Server socket */
}

@property (nonatomic, assign) id<ICTcpServerDelegate>       delegate;

@property (nonatomic, assign) id<NSStreamDelegate>          streamDelegate;

@property (nonatomic, readonly) NSInputStream   * inputStream;                  /**< Serial input stream */
@property (nonatomic, readonly) NSOutputStream  * outputStream;                 /**< Serial output stream */
@property (nonatomic, readonly) NSString        * peerName;                     /**< IP address of the remote host */
@property (nonatomic, assign)   NSUInteger        port;                         /**< Tcp port of the server */

-(BOOL)startServer;

-(void)stopServer;

@end

@protocol ICTcpServerDelegate

-(void)connectionEstablished:(ICTcpServer *)sender;       //Called on Main Thread

@end
