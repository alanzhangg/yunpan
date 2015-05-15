//
//  NetWorkingRequest.h
//  NotePad
//
//  Created by Team E Alanzhangg on 15/2/9.
//  Copyright (c) 2015年 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPAPIClient.h"
#import "Global.h"

@interface NetWorkingRequest : NSObject

+ (void)synthronizationWithString:(NSDictionary *)dic andBlock:(void (^)(id data, NSError * error))block;

@end
