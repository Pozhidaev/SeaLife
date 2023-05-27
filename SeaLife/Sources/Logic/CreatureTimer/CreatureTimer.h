//
//  CreatureTimer.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 12.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CreatureTimerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreatureTimer : NSObject<CreatureTimerProtocol>

- (void)setTargetQueue:(dispatch_queue_t)targetQueue;

@end

NS_ASSUME_NONNULL_END
