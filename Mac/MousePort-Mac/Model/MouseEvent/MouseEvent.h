//
//  MouseEvent.h
//  PointerKit
//
//  Created by iPAWiND on 4/27/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    moved,
    leftDown,
    leftUp,
    leftDragged,
    rightDown,
    rightUp,
    rightDragged
} MouseEventType;

@interface MouseEvent : NSObject


@property (nonatomic) MouseEventType type;
@property (nonatomic) int deltaX;
@property (nonatomic) int deltaY;

-(instancetype)initWithType:(MouseEventType)type;
-(instancetype)initWithType:(MouseEventType)type deltaX:(int)deltaX deltaY:(int)deltaY;
-(instancetype)initFromDict:(NSDictionary *)dict;

-(NSDictionary *)toDict;

@end

NS_ASSUME_NONNULL_END
