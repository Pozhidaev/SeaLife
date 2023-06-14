//
//  CreatureTimer.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 12.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreatureTimer.h"

@interface CreatureTimer()
{
    dispatch_queue_t _queue;
    dispatch_source_t _timer;
    void(^_timerBlock)(void);
    
    int _timerPausedCounter;
}
@end

@implementation CreatureTimer

#pragma mark - Memory

- (instancetype)initWithTargetQueue:(dispatch_queue_t)targetQueue
                              block:(void(^)(void))timerBlock
{
    self = [super init];
    if (self) {
        _timerBlock = timerBlock;
        _timerPausedCounter = 0;
        
        _queue = dispatch_queue_create("timer_private_queue", DISPATCH_QUEUE_SERIAL_INACTIVE);
        dispatch_set_target_queue(_queue, targetQueue);
        dispatch_activate(_queue);
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        if (_timer) {
            dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
            uint64_t intervalTime = (int64_t)((double)1.0 * NSEC_PER_SEC);
            dispatch_source_set_timer(_timer, startTime, intervalTime, 0);

            __weak typeof(self) weakSelf = self;
            dispatch_source_set_event_handler(_timer, ^{
                typeof(self) strongSelf = weakSelf;
                if (strongSelf && strongSelf->_timerBlock) {
                    strongSelf->_timerBlock();
                }
            });
        }
    }
    return self;
}

- (void)dealloc
{
    if (_timerPausedCounter <= 0) {
        for (int i = _timerPausedCounter; i <= 0; i++) {
            dispatch_resume(self->_timer);
        }
    }
}

#pragma mark - Public

- (void)setSpeed:(float)speed
{
    int64_t currentStartOffset = (int64_t)((double)speed * NSEC_PER_SEC);
    int64_t randomTimerDelta = (int64_t)(arc4random_uniform(1000 * speed) * USEC_PER_SEC);
    
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, randomTimerDelta + currentStartOffset);
    uint64_t intervalTime = (int64_t)((double)speed * NSEC_PER_SEC);
    dispatch_source_set_timer(_timer, startTime, intervalTime, 0);
}

- (void)start
{
    if (self->_timerPausedCounter == 0) {
        self->_timerPausedCounter += 1;
        dispatch_resume(self->_timer);
    }
}

- (void)stop
{
    [self pause];
}

- (void)pause
{
    if (self->_timerPausedCounter > 0) {
        self->_timerPausedCounter -= 1;
        dispatch_suspend(self->_timer);
    }
}

@end
