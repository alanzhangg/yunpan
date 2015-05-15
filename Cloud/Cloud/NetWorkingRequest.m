//
//  NetWorkingRequest.m
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/9.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import "NetWorkingRequest.h"

@implementation NetWorkingRequest

+ (NSString *)generetionParam:(NSDictionary *)dic{
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    NSString * urlStr = [NSString stringWithFormat:@"%@", [ud objectForKey:@"server"]];
    NSString * param = [dic objectForKey:@"param"];
    NSString * aslp = [dic objectForKey:@"aslp"];
    NSString * postStr = [NSString stringWithFormat:@"/r/jd?cmd=%@&sourceAppId=%@&aslp=%@&%@&authentication=%@", CMD, SOURCEAPPID, aslp, param, [ud objectForKey:@"sid"]];
    postStr = [urlStr stringByAppendingString:postStr];
    
    return postStr;
}

+ (void)synthronizationWithString:(NSDictionary *)dic andBlock:(void (^)(id, NSError *))block{
    NSString * str = [self generetionParam:dic];
    NSLog(@"%@", str);
    [[AFHTTPAPIClient shareClient] postPath:[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block) {
            block(responseObject, nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (block) {
            block(nil, error);
        }
    }];
}

@end
