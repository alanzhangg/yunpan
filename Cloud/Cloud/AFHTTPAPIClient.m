//
//  AFHTTPAPIClient.m
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/9.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "AFHTTPAPIClient.h"
#import "AFHTTPRequestOperation.h"
#import "Reachability.h"

@implementation AFHTTPAPIClient

+ (int)checkNetworkStatus{
    Reachability * reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    return reach.currentReachabilityStatus;
}

+ (AFHTTPAPIClient *)shareClient{
    static AFHTTPAPIClient * _shareClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareClient = [[AFHTTPAPIClient alloc] initWithBaseURL:[NSURL URLWithString: @""]];
        _shareClient.allowsInvalidSSLCertificate = YES;
    });
    
    return _shareClient;
}

- (id)initWithBaseURL:(NSURL *)url{
    if (self = [super initWithBaseURL:url]) {
        [self registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    }
    return self;
}

@end
