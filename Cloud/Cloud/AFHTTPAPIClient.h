//
//  AFHTTPAPIClient.h
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/9.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "AFHTTPClient.h"
#import "Reachability.h"

@interface AFHTTPAPIClient : AFHTTPClient

+ (AFHTTPAPIClient *)shareClient;
+ (int)checkNetworkStatus;

@end
