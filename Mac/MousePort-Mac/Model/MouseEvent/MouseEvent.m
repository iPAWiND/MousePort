//
//  MouseEvent.m
//  PointerKit
//
//  Created by iPAWiND on 4/27/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import "MouseEvent.h"

@implementation MouseEvent
    
-(instancetype)initWithType:(MouseEventType)type phase:(MouseEventPhase)phase deltaX:(int)deltaX deltaY:(int)deltaY {
    
    self = [super init];
    
    self.type = type;
    self.phase = phase;
    
    self.deltaX = deltaX;
    self.deltaY = deltaY;
    
    return self;
}

-(NSDictionary *)toDict {
    return @{ @"event" : @(self.type), @"phase" : @(self.phase), @"x" : @(self.deltaX), @"y" : @(self.deltaY) };
}

@end
