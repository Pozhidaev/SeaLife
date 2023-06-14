//
//  CreatureTimerProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 12.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CreatureTimerProtocol <NSObject>

- (instancetype)initWithTargetQueue:(dispatch_queue_t)targetQueue
                              block:(void(^)(void))timerBlock;

- (void)setSpeed:(float)speed;

- (void)start;
- (void)stop;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
