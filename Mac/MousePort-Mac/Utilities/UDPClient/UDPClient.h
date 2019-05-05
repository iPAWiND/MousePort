//
//  UDPClient.h
//  PointerKit-Mac
//
//  Created by iPAWiND on 4/28/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"
#import "ConnectionDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UDPClient : NSObject <Connection>

@property (strong, nonatomic) id <ConnectionDelegate> delegate;

-(instancetype)initWithServerAddress:(NSString *)address port:(int)port;

-(void)connect;
-(void)monitorConnection;

@end

NS_ASSUME_NONNULL_END
