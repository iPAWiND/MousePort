//
//  Utilities.m
//  MousePortSender
//
//  Created by iPAWiND on 4/29/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+(NSArray *)getLanIps {
    
    NSMutableArray *possibleIps = [@[] mutableCopy];
    
    NSString *arpOutput = [self arp];
    
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:@"\\((.*?)\\)" options:NSRegularExpressionSearch error:nil];
    
    NSArray *matches = [expression matchesInString:arpOutput
                                           options:0
                                             range:NSMakeRange(0, [arpOutput length])];
    
    for (NSTextCheckingResult *match in matches) {
        
        NSRange matchRange = [match rangeAtIndex:1];
        NSString *matchString = [arpOutput substringWithRange:matchRange];
        NSLog(@"%@", matchString);
        
        [possibleIps addObject:matchString];
    }
    
    return possibleIps;
}

+(NSString *)arp {
    
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/usr/sbin/arp";
    task.arguments = @[@"-a"];
    task.standardOutput = pipe;
    
    [task launch];
    
    NSData *data = [file readDataToEndOfFile];
    [file closeFile];
    
    NSString *arpOutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    //NSLog (@"arp returned:\n%@", arpOutput);
    return arpOutput;
}

@end
