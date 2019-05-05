//
//  MouseEvent.m
//  PointerKit
//
//  Created by iPAWiND on 4/27/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import "MouseEvent.h"

@implementation MouseEvent

-(instancetype)initWithType:(MouseEventType)type deltaX:(int)deltaX deltaY:(int)deltaY {
    
    self = [super init];
    
    self.type = type;
    
    self.deltaX = deltaX;
    self.deltaY = deltaY;
    
    return self;
}

-(instancetype)initWithType:(MouseEventType)type {
    return [self initWithType:type deltaX:0 deltaY:0];
}

-(instancetype)initFromDict:(NSDictionary *)dict {
    
    NSNumber *event = dict[@"event"];
    NSNumber *x = dict[@"x"];
    NSNumber *y = dict[@"y"];
    
    MouseEventType type = (MouseEventType) event.intValue;

    return [self initWithType:type deltaX:x.intValue deltaY:y.intValue];
}

-(NSDictionary *)toDict {
    return @{ @"event" : @(self.type), @"x" : @(self.deltaX), @"y" : @(self.deltaY) };
}

@end
