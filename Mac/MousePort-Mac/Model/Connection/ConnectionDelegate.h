//
//  ConnectionDelegate.h
//  PointerKit
//
//  Created by iPAWiND on 4/29/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Connection.h"

#ifndef ConnectionDelegate_h
#define ConnectionDelegate_h

@protocol ConnectionDelegate

-(void)connectionDidReceiveData:(NSData *)data;
-(void)connectionDidConnect:(id <Connection>)connection;
-(void)connectionDidDisconnect:(id <Connection>)connection;

@end

#endif /* ConnectionDelegate_h */
