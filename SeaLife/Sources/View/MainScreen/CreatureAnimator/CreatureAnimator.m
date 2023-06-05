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
    NSMutableDictionary<NSUUID *, NSArray<CAAnimation *> *> *_animationsDictionary;
    NSMutableDictionary<NSUUID *, void(^)(void)> *_completionsDictionary;
    NSMutableDictionary<NSUUID *, CALayer *> *_layersDictionary;
}

@end

@implementation CreatureAnimator

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animationsDictionary = [[NSMutableDictionary alloc] init];
        _completionsDictionary = [[NSMutableDictionary alloc] init];
        _layersDictionary = [[NSMutableDictionary alloc] init];

        self.animationSpeed = 0;
    }
    return self;
}

#pragma mark - Public

- (void)play
{
    for (CALayer *layer in _layersDictionary.allValues) {
        CFTimeInterval pausedTime = [layer timeOffset];
        layer.speed = 1.0;
        layer.timeOffset = 0.0;
        layer.beginTime = 0.0;
        CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        layer.beginTime = timeSincePause;
    }
}

- (void)pause
{
    for (CALayer *layer in _layersDictionary.allValues) {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
    }
}

- (void)reset
{
    [_animationsDictionary removeAllObjects];
    [_completionsDictionary removeAllObjects];
    [_layersDictionary removeAllObjects];
}

- (void)removeAllAnimationsForCreatureUUID:(NSUUID *)creatureUUID
{
    [_animationsDictionary removeObjectForKey: creatureUUID];
    [_completionsDictionary removeObjectForKey: creatureUUID];
    [_layersDictionary removeObjectForKey: creatureUUID];
}

- (void)performAnimationsForTurn:(Turn *)turn
                        forLayer:(CALayer *)layer
                  withCompletion:(void(^)(void))completion
{
    NSArray *animations = [self animationsForTurn:turn layer:layer];
    for (CAAnimation *animation in animations) {
        animation.delegate = self;
        [animation setValue:turn.creature.uuid forKey:kAnimationUUIDKey];
    }

    CABasicAnimation *lastAnimation = [animations lastObject];
    lastAnimation.removedOnCompletion = NO;
    lastAnimation.fillMode = kCAFillModeForwards;

    CATransform3D finalTransform = [[lastAnimation valueForKey:kAnimationFinalTransform] CATransform3DValue];
    
    __weak CALayer *weakLayer = layer;
    __weak typeof(self) weakSelf = self;
    void(^lastAnimationCompletion)(void) = ^{
        [weakLayer removeAllAnimations];
        weakLayer.transform = finalTransform;
        CGFloat centerX = turn.finalPosition.x * weakSelf.cellSize.width + weakSelf.cellSize.width / 2.0;
        CGFloat centerY = turn.finalPosition.y * weakSelf.cellSize.height + weakSelf.cellSize.height / 2.0;
        weakLayer.position = CGPointMake(centerX, centerY);
        completion();
    };

    [_layersDictionary setObject:layer forKey:turn.creature.uuid];

    [_completionsDictionary setObject:lastAnimationCompletion forKey:turn.creature.uuid];

    [_animationsDictionary setObject:animations forKey:turn.creature.uuid];

    [self startNextAnimationsForCreatureId:turn.creature.uuid];
}

- (void)startNextAnimationsForCreatureId:(NSUUID *)uuid
{
    NSMutableArray *animationsArray = [[_animationsDictionary objectForKey:uuid] mutableCopy];
    CAAnimation *nextAnimation = [animationsArray firstObject];

    if (!nextAnimation) {
        [_layersDictionary removeObjectForKey:uuid];
        [_animationsDictionary removeObjectForKey:uuid];
        void(^completion)(void) = _completionsDictionary[uuid];
        if (completion) {
            _completionsDictionary[uuid] = nil;
            completion();
        }
        return;
    }
    
    [animationsArray removeObject:nextAnimation];
    [_animationsDictionary setObject:animationsArray forKey:uuid];
    
    [Utils performOnMainThread:^{
        CALayer *layer = [self->_layersDictionary objectForKey:uuid];
        [layer addAnimation:nextAnimation forKey:kAnimationKey];
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
    NSUUID *uuid = [anim valueForKey:kAnimationUUIDKey];

    [self startNextAnimationsForCreatureId:uuid];
}

- (NSArray *)animationsForTurn:(Turn *)turn
                         layer:(CALayer *)layer
{
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

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue
{
    [Utils performOnMainThread:^{
        CALayer *layer = turn.creature.visualComponent.layer;
        [self performAnimationsForTurn:turn
                              forLayer:layer
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
@end
