//
//  Utils.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 21.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (void)performOnMainThread:(void(^)(void))performBlock;

+ (void)performOnMainThreadAndWait:(void(^)(void))performBlock;

@end

NS_ASSUME_NONNULL_END
