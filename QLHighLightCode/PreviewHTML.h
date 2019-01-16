//
//  PreviewHTML.h
//  qltest
//
//  Created by King on 2018/12/12.
//  Copyright © 2018 King. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreviewHTML : NSObject

/** 获取渲染后的html */
+ (NSString *)render:(NSURL *)file_url;

@end

NS_ASSUME_NONNULL_END
