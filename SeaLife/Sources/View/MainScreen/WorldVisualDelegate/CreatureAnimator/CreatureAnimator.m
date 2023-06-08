//
//  CreatureAnimator.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreatureAnimator.h"

#import "Turn.h"
#import "AnimationsFactory.h"
#import "CreatureProtocol.h"
#import "Direction.h"
#import "TurnType.h"
#import "Utils.h"
#import "WorldPosition.h"

@interface CreatureAnimator() <CAAnimationDelegate>
{
    NSMutableArray *_animationsArray;
    void(^_completion)(void);
}

@property (nonatomic, readwrite) UIImageView *visualComponent;

@end

@implementation CreatureAnimator

- (instancetype)initWithVisualComponent:(UIImageView *)visualComponent
{
    self = [super init];
    if (self) {
        _animationsArray = [[NSMutableArray alloc] init];
        self.visualComponent = visualComponent;
        self.animationSpeed = 0;
    }
    return self;
}

#pragma mark - Public

- (void)play
{
    [Utils performOnMainThread:^{
        CALayer *layer = self.visualComponent.layer;
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }];
}

- (void)pause
{
    [Utils performOnMainThread:^{
        CALayer *layer = self.visualComponent.layer;
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }];
}

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue
{
    [Utils performOnMainThread:^{
        [self performAnimationsForTurn:turn
                        withCompletion:^{
            if (turn.direction != DirectionNone) {
                turn.creature.direction = turn.direction;
            }
            
            dispatch_async(completionQueue, ^{
                if (completion) {
                    completion();
                }
            });
        }];
    }];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    void(^preparation)(void) = [anim valueForKey:kAnimationPreparationKey];
    if (preparation) { preparation(); }
}

- (void)animationDidStop:(CAAnimation *)anim
                finished:(BOOL)flag
{
    if (flag) {
        [self startNextAnimation];
    } else {
        [self animationsInterrupted];
    }
}

#pragma mark - Private

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
{
    NSArray *animations = [self animationsForTurn:turn];
    for (CAAnimation *animation in animations) {
        animation.delegate = self;
    }

    CABasicAnimation *lastAnimation = [animations lastObject];
    lastAnimation.removedOnCompletion = NO;
    lastAnimation.fillMode = kCAFillModeForwards;

    CATransform3D finalTransform = [[lastAnimation valueForKey:kAnimationFinalTransform] CATransform3DValue];
    
    __weak typeof(self) weakSelf = self;
    void(^lastAnimationCompletion)(void) = ^{
        if (!weakSelf) { return; }
        typeof(self) sSelf = weakSelf;

        CALayer *layer = sSelf.visualComponent.layer;
        [layer removeAllAnimations];
        layer.transform = finalTransform;
        CGFloat centerX = turn.finalPosition.x * sSelf.cellSize.width + sSelf.cellSize.width / 2.0;
        CGFloat centerY = turn.finalPosition.y * sSelf.cellSize.height + sSelf.cellSize.height / 2.0;
        layer.position = CGPointMake(centerX, centerY);
        completion();
    };

    _completion = lastAnimationCompletion;

    _animationsArray = [animations mutableCopy];

    [self startNextAnimation];
}

- (void)startNextAnimation
{
    CAAnimation *nextAnimation = [_animationsArray firstObject];
    if (!nextAnimation) {
        _animationsArray = nil;
        if (_completion) {
            void(^_tCompletion)(void) = _completion;
            _completion = nil;
            _tCompletion();
        }
        return;
    }
    
    [_animationsArray removeObject:nextAnimation];
    
    [Utils performOnMainThread:^{
        CALayer *layer = self.visualComponent.layer;
        [layer addAnimation:nextAnimation forKey:kAnimationKey];
    }];
}

- (void)animationsInterrupted
{
    _animationsArray = nil;
    if (_completion) {
        void(^_tCompletion)(void) = _completion;
        _completion = nil;
        _tCompletion();
    }
}

- (NSArray *)animationsForTurn:(Turn *)turn
{
    CALayer *layer = self.visualComponent.layer;
    switch (turn.type) {
        case TurnTypeCreatureEmpty: {
            return [AnimationsFactory emptyAnimationsForLayer:layer
                                                     duration:self.animationSpeed];
        } break;
            
        case TurnTypeCreatureMove: {
            return [AnimationsFactory moveAnimationsFromDirection:turn.creature.direction
                                                      toDirection:turn.direction
                                                            layer:layer
                                                         duration:self.animationSpeed
                                                         cellSize:self.cellSize];
        } break;

        case TurnTypeCreatureEat: {
            return [AnimationsFactory eatAnimationsFromDirection:turn.creature.direction
                                                     toDirection:turn.direction
                                                           layer:layer
                                                        duration:self.animationSpeed
                                                        cellSize:self.cellSize];
        } break;

        case TurnTypeCreatureReproduce: {
            return [AnimationsFactory reproduceAnimationsFromDirection:turn.creature.direction
                                                           toDirection:turn.direction
                                                                 layer:layer
                                                              duration:self.animationSpeed
                                                              cellSize:self.cellSize];
        } break;
            
        case TurnTypeCreatureBorn: {
            return [AnimationsFactory bornAnimationsWithDuration:self.animationSpeed
                                                        cellSize:self.cellSize];
        } break;
            
        case TurnTypeCreatureDie: {
            return [AnimationsFactory dieAnimationsForLayer:layer
                                                   duration:self.animationSpeed
                                                   cellSize:self.cellSize];
        } break;
    }
    assert(false); // must be case in switch for any scenario
    return [AnimationsFactory emptyAnimationsForLayer:layer
                                             duration:0];
}

@end
