//
//  Utils.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 21.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (void)performOnMainThread:(void(^)(void))performBlock
{
    if ([NSThread isMainThread]) {
        performBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            performBlock();
        });
    }
}

+ (void)performOnMainThreadAndWait:(void(^)(void))performBlock
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [self performOnMainThread:^{
        performBlock();
        dispatch_group_leave(group);
    }];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

@end
