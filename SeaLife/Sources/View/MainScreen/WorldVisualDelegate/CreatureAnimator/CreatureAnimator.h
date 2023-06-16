//
//  AnimationsController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Turn;

NS_ASSUME_NONNULL_BEGIN

@interface CreatureAnimator : NSObject

@property (nonatomic) CGSize cellSize;
@property (nonatomic) float animationSpeed;

@property (nonatomic, weak) UIImageView *visualComponent;

- (void)play;
- (void)pause;

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue;

@end

NS_ASSUME_NONNULL_END
