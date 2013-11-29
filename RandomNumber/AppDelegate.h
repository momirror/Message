//
//  AppDelegate.h
//  RandomNumber
//
//  Created by msp on 13-11-28.
//  Copyright (c) 2013年 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AsyncUdpSocket.h"
#define MESSAGE_SEARCH_FLAG 0xFFFF
#define MESSAGE_REPLY_FLAG 0xFFFF
#define MULTICAST_SEARCH 0xFFFE

typedef struct
{
    int  iFlag;
    int  cmd;
    float  iVersion;
    char   name[100];
    int    address;
    int    iPort;
    
}MULTICAST_INFO;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    AsyncUdpSocket * m_socket;
    int    m_iPort;
}



@property (assign) IBOutlet NSWindow *window;


- (void)SearchAllUsers;
@end
