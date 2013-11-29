//
//  Data.m
//  RandomNumber
//
//  Created by msp on 13-11-28.
//  Copyright (c) 2013年 msp. All rights reserved.
//

#import "Data.h"

@implementation Data

- (IBAction)generateNum:(id)sender
{
    NSLog(@"aaa");
    int iRandNum = arc4random()%10000;
    [m_pTextField setIntValue:iRandNum];
}

@end
