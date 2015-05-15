//
//  NRCollectImageData.h
//  NeedsReport
//
//  Created by Team E Alanzhangg on 10/14/14.
//  Copyright (c) 2014 Team E Alanzhangg. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AssetsLibrary;

@interface NRCollectImageData : NSObject

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) ALAsset * result;

@end