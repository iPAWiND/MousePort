//
//  UDPClient.m
//  PointerKit-Mac
//
//  Created by iPAWiND on 4/28/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import "UDPClient.h"
#import "GCDAsyncUdpSocket.h"

#define TEST_MESSAGE @"ping"
#define TIMEOUT 5

@interface UDPClient() <GCDAsyncUdpSocketDelegate>
    
    @property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;
    
    @property (strong, nonatomic) NSString *address;
    @property (nonatomic) int port;
    @property (nonatomic) bool connected;
    @property (nonatomic) bool monitorStatus;
    
    @end

@implementation UDPClient
    
-(instancetype)initWithServerAddress:(NSString *)address port:(int)port {
    
    self = [self init];
    
    self.address = address;
    self.port = port;
    
    self.udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.udpSocket.delegate = self;
    
    if (![self start]) {
        return nil;
    }
    
    return self;
}
    
-(bool)start {
    
    NSError *error = nil;
    
    if (![self.udpSocket bindToPort:0 error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        
        return false;
    }
    
    if (![self.udpSocket beginReceiving:&error])
    {
        NSLog(@"Error receive");
        
        return false;
    }
    
    return true;
}
    
-(void)stop {
    [self.udpSocket close];
}
    
-(void)connect {
    [self sendData:[TEST_MESSAGE dataUsingEncoding:NSUTF8StringEncoding]];
}
    
- (void)sendData:(NSData *)data {
    [self.udpSocket sendData:data toHost:self.address port:self.port withTimeout:TIMEOUT tag:0];
}
    
- (void)sendDictMessage:(NSDictionary *)dict {
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    
    [self sendData:data];
}
    
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"string %@", string);
    
    bool success = string && [string isEqualToString:TEST_MESSAGE];
    
    self.monitorStatus = success;
    
    if (success && self.connected == false) {
        
        [self.delegate connectionDidConnect:self];
        
        self.connected = true;
    }
}
    
-(void)monitorConnection {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Change connection status
        self.monitorStatus = false;
        
        // Try to connect again
        [self connect];
        
        sleep(TIMEOUT);
        
        // If monitor status is change to connected, it means the server responded back
        if (self.monitorStatus == true) {
            
            // Recheck the connection
            [self monitorConnection];
            
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            // Didn't connect again.
            [self.delegate connectionDidDisconnect:self];
        });
        
    });
}
    
    @end
