//
//  Connection.h
//  PointerKit
//
//  Created by iPAWiND on 4/28/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#ifndef Connection_h
#define Connection_h

@protocol Connection

-(void)sendData:(NSData *)data;
-(void)sendDictMessage:(NSDictionary *)dict;

@optional
-(void)monitorConnection;

@end

#endif /* Connection_h */
