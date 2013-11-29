//
//  AppDelegate.m
//  RandomNumber
//
//  Created by msp on 13-11-28.
//  Copyright (c) 2013年 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSLog(@"initial");
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(SearchAllUsers) userInfo:nil repeats:NO];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(TopWindow) userInfo:nil repeats:YES];
    
}


//- (void)SearchAllUsers
//{
//    //消息气泡
//    static int newScore = 1;
//    [[[NSApplication sharedApplication] dockTile] setBadgeLabel:[NSString stringWithFormat:@"%d", newScore++]];
//}


//弹出窗口
- (void)TopWindow
{
//    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
//    [self LauOtherApp];
}

- (void)LauOtherApp
{
    NSLog(@"%d",[[NSWorkspace sharedWorkspace] launchApplication:@"Test.app"]);
}

- (void)SearchAllUsers
{
    
    m_socket=[[AsyncUdpSocket alloc] initWithDelegate:self];
    
    m_iPort=4333;
    
    NSError *error;
    
    [m_socket bindToPort:m_iPort error:&error];
    [m_socket enableBroadcast:YES error:&error];
    [m_socket joinMulticastGroup:@"224.0.0.2" error:nil];
    
    [m_socket receiveWithTimeout:-1 tag:0];
    [self SearchUser];
//    m_pTimer = [NSTimer scheduledTimerWithTimeInterval:0.0f target:self selector:@selector(SearchDevice) userInfo:nil repeats:NO];
    
    /*测试一下*/
    NSLog(@"test");
    
    
    
    
}

- (void)SearchUser
{
    MULTICAST_INFO info;
    memset(&info, 0, sizeof(info));
    info.iFlag = MESSAGE_SEARCH_FLAG;
    info.cmd = MULTICAST_SEARCH;
    info.iVersion = 1.0;
    
    char * cmdBuff = new char[sizeof(info)];
    memset(cmdBuff, 0, sizeof(sizeof(info)));
    memcpy(cmdBuff, &info, sizeof(info));
    
    
    NSData *data=[NSData dataWithBytes:cmdBuff length:sizeof(MULTICAST_INFO)];
    
    BOOL bResult = [m_socket sendData :data toHost:@"224.0.0.2" port:m_iPort withTimeout:5 tag:1];
    if(!bResult)
    {
        NSLog(@"发送失败");
    }
    
    NSLog(@"begin scan");
    delete []cmdBuff;
    cmdBuff = nil;
    
}


-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    
    char * ch = (char *)[data bytes];
    MULTICAST_INFO *info = (MULTICAST_INFO*)ch;
    
    if(info->address == 0)
    {
        return NO;
    }
        
    if(info->iFlag == MESSAGE_REPLY_FLAG)
    {
        unsigned long ip = info->address;
        NSString * strIP = [self IntToBinaryString:ip];
        NSRange range;
        
        range.location = 0;
        range.length = 8;
        int iIP0 = (int)[self BanilyStringToLong:[strIP substringWithRange:range]];
        
        range.location = 8;
        range.length = 8;
        int iIP1 = (int)[self BanilyStringToLong:[strIP substringWithRange:range]];
        
        range.location = 16;
        range.length = 8;
        int iIP2 = (int)[self BanilyStringToLong:[strIP substringWithRange:range]];
        
        range.location = 24;
        range.length = 8;
        int iIP3 = (int)[self BanilyStringToLong:[strIP substringWithRange:range]];
        
        NSString * strInfo = [NSString stringWithFormat:@"%s~%d.%d.%d.%d:%d",info->name,iIP3,iIP2,iIP1,iIP0,info->iPort];
        NSLog(@"userInfo->%@",strInfo);
//        [self AddInfo:strInfo];
    }
    
    
    
    return NO;
    
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    
    NSLog(@"not received");
    return YES;
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    //网络断开时
    NSLog(@"%@",error);
    
    NSLog(@"not send");
    return YES;
    
}


- (NSString*)IntToBinaryString:(unsigned long)iValue//将int类型转换为二进制字符串
{
    NSString * str = @"";
    int iTemp;
    
    while (iValue != 0) {
        
        iTemp = iValue % 2;
        iValue = iValue/2;
        str = [str stringByAppendingFormat:@"%d",iTemp];//这里的结果是反的
    }
    
    while ([str length] != 32) {
        str = [str stringByAppendingString:@"0"];
    }
    
    str = [self ReverseString:str];
    
    return [str retain];
}

- (NSString*)ReverseString:(NSString*)str//字符串反转
{
    int iLen = (int)[str length];
    char p[100];
    memset(p, 0, 100);
    memcpy(p, [str UTF8String], iLen);
    
    int iMid = iLen/2;
    for(int i = 0;i < iMid;i++)
    {
        char ch = p[iLen-1-i];
        p[iLen-1-i] = p[i];
        p[i] = ch;
    }
    
    return [NSString stringWithUTF8String:p];
}


-(long long)BanilyStringToLong:(NSString*)str
{
    int iLen = (int)[str length];
    const char * p = [str UTF8String];
    
    long long lResult = 0;
    int k = 0;
    for(int i = iLen - 1;i >= 0;i--)
    {
        if(p[i] == '1')
        {
            lResult += pow(2, k);
        }
        k++;
    }
    
    return lResult;
    
}

@end
