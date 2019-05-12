//
//  ViewController.m
//  MousePortSender
//
//  Created by iPAWiND on 4/27/19.
//  Copyright © 2019 iPAWiND. All rights reserved.
//


#import "ViewController.h"
#import "UDPClient.h"
#import "Utilities/Utilities.h"
#import "MouseEvent.h"

@interface ViewController () <ConnectionDelegate>

@property (strong, nonatomic) UDPClient *udpConnection;

@property (strong, nonatomic) NSArray *possibleIps;

@property (strong, nonatomic) id<Connection> connection;

@property (strong) IBOutlet NSTextField *connectedLabel;
@property (strong) IBOutlet NSView *searchingView;
@property (strong) IBOutlet NSProgressIndicator *spinner;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UDP
    [self initConnection];
    
    // Add event monitor
    [self addEvent];
    
    [self updateView];
}

-(void)initConnection {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.possibleIps = [Utilities getLanIps];
        
        NSMutableArray *clients = [@[] mutableCopy];
        
        for (NSString *ip in self.possibleIps) {
            
            UDPClient *client = [[UDPClient alloc] initWithServerAddress:ip port:1011];
            
            client.delegate = self;
            
            [client connect];
            
            // Reatain a block copy
            [clients addObject:client];
        }
        
        sleep(2.5);
        
        // If after 2.5 seconds we don't have a connection, it means none of the ips responded, check again;
        if (self.connection) return;
        
        [self initConnection];
    });
}

-(void)connectionDidConnect:(id <Connection>)connection {
    
    // Make sure no connection is active, otherwise no need to set it again.
    if (self.connection) return;
    
    self.connection = connection;
    
    [self.connection monitorConnection];
    
    [self updateView];
}

-(void)connectionDidDisconnect:(id <Connection>)connection {
    
    // Make sure it's the connection we're monitoring
    if (connection != self.connection) return;
    
    self.connection = nil;
    
    [self initConnection];
    
    [self updateView];
}

- (void)connectionDidReceiveData:(NSData *)data {
    
}


-(void)updateView {
    
    bool connected = self.connection != nil;
    
    [self.searchingView setHidden:connected];
    [self.connectedLabel setHidden:!connected];
    [self.spinner startAnimation:nil];
}

-(void)viewDidAppear {
    [super viewDidAppear];
    
    NSApplicationPresentationOptions options = NSApplicationPresentationHideDock | NSApplicationPresentationHideMenuBar | NSApplicationPresentationDisableAppleMenu;
    
    NSDictionary *dict = @{NSFullScreenModeApplicationPresentationOptions : [NSNumber numberWithUnsignedLong:options]};
    
    [self.view enterFullScreenMode:[NSScreen mainScreen] withOptions:dict];
}


-(void)addEvent {
    
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskMouseMoved | NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDown | NSEventMaskLeftMouseDragged | NSEventMaskRightMouseUp | NSEventMaskRightMouseDown | NSEventMaskRightMouseDragged | NSEventMaskScrollWheel handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        
        // Make sure we've a connection
        if (!self.connection) { return event; }
        
        int deltaX = event.deltaX;
        int deltaY = event.deltaY;
        
        MouseEventType type;
        
        switch (event.type) {
            case kCGEventMouseMoved:
                type = moved;
                break;
            case kCGEventLeftMouseDragged:
                type = leftDragged;
                break;
            case kCGEventLeftMouseUp:
                type = leftUp;
                break;
            case kCGEventLeftMouseDown:
                type = leftDown;
                break;
            case kCGEventRightMouseDragged:
                type = rightDragged;
                break;
            case kCGEventRightMouseUp:
                type = rightUp;
                break;
            case kCGEventRightMouseDown:
                type = rightDown;
                break;
            case kCGEventScrollWheel:
                type = scroll;
                break;
        }
        
        MouseEventPhase phase = unknown;
        
        if (type == scroll) {
            
            deltaX = event.scrollingDeltaX;
            deltaY = event.scrollingDeltaY;
            
            if (event.phase == NSEventPhaseBegan) {
                phase = began;
            }
            else if (event.phase == NSEventPhaseChanged) {
                phase = changed;
            }
            else if (event.phase == NSEventPhaseEnded){
                phase = ended;
            }
        }
        
        MouseEvent *mouseEvent = [[MouseEvent alloc] initWithType:type phase:phase deltaX:deltaX deltaY:deltaY];
        
        NSDictionary *dict = [mouseEvent toDict];
        
        [self.connection sendDictMessage:dict];
        
        return event;
    }];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

@end
