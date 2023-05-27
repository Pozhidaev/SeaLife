//
//  CreaturesView.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreaturesView.h"
#import "UIImage+Creature.h"
#import "Turn.h"
#import "AnimationsController.h"
#import "CreatureProtocol.h"
#import "Direction.h"
#import "TurnType.h"
#import "Utils.h"
#import "WorldPosition.h"

@interface CreaturesView()
{
    AnimationsController *_animationController;
    NSMutableDictionary *_imageViewsDictionary;
}

@end


@implementation CreaturesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageViewsDictionary = [[NSMutableDictionary alloc] init];
        _animationController = [[AnimationsController alloc] init];

        self.cellSize = CGSizeZero;
        self.animationSpeed = 0.0;
    }
    return self;
}

#pragma mark - Accessors

- (void)setCellSize:(CGSize)cellSize
{
    if (CGSizeEqualToSize(_cellSize, cellSize)) { return; }
    [self willChangeValueForKey:@"cellSize"];
    _cellSize = cellSize;
    [self didChangeValueForKey:@"cellSize"];

    _animationController.cellSize = cellSize;
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    if (_animationSpeed == animationSpeed) { return; }
    [self willChangeValueForKey:@"animationSpeed"];
    _animationSpeed = animationSpeed;
    [self didChangeValueForKey:@"animationSpeed"];

    _animationController.animationSpeed = animationSpeed;
}

#pragma mark - WorldVisualDelegate

- (void)play
{
    [_animationController play];
}

- (void)stop
{
    [_animationController stop];
}

- (void)reset
{
    [_imageViewsDictionary removeAllObjects];

    [_animationController reset];

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)createImageViewForCreatures:(NSSet<id<CreatureProtocol>> *)creatures
{
    for (id<CreatureProtocol> creature in creatures) {
        [self createImageViewForCreature:creature];
    }
}

- (void)createImageViewForCreature:(id<CreatureProtocol>)creature
{
    UIImage *image = [UIImage imageFor:creature];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor colorNamed:@"CreaturesTintColor"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.cellSize.width, self.cellSize.height);
    frame.origin = CGPointMake(self.cellSize.width * creature.position.x,
                               self.cellSize.height * creature.position.y);
    CGFloat delta = 0;
    if (frame.size.width > kCreatureImageViewMinSizeForReducing) {
        delta = frame.size.width * kCreatureImageViewReducingCoeficient;
    }
    imageView.frame = CGRectInset(frame, delta, delta);

    [_imageViewsDictionary setObject:imageView forKey:creature.uuid];
    [self addSubview:imageView];
}

- (void)removeImageViewForCreature:(id<CreatureProtocol>)creature
{
    assert(creature);

    UIImageView *imageView = [_imageViewsDictionary objectForKey:creature.uuid];
    [imageView removeFromSuperview];

    assert(imageView);
    
    [_imageViewsDictionary removeObjectForKey:creature.uuid];
    
    [_animationController removeAllAnimationsForCreatureUUID:creature.uuid];
}

- (void)redrawFromCellSize:(CGSize)fromCellSize
                toCellSize:(CGSize)toCellSize
{
    CGFloat xCoeficient = toCellSize.width / fromCellSize.width;
    CGFloat yCoeficient = toCellSize.height / fromCellSize.height;
    
    for (UIImageView *imageView in _imageViewsDictionary.allValues) {
        CGRect bounds = imageView.bounds;
        bounds.size = CGSizeMake(bounds.size.width * xCoeficient, bounds.size.height * yCoeficient);
        imageView.bounds = bounds;
        CGPoint center = imageView.center;
        center = CGPointMake(center.x * xCoeficient, center.y * yCoeficient);
        imageView.center = center;
    }
}

- (void)performAnimationsForTurn:(Turn *)turn
                  withCompletion:(void(^)(void))completion
                 completionQueue:(dispatch_queue_t)completionQueue
{
    void(^animationPreparation)(void);
    void(^animationCompletion)(void);
    
    switch (turn.type) {
        case TurnTypeCreatureEmpty: {
        } break;

        case TurnTypeCreatureMove: {
        } break;
            
        case TurnTypeCreatureEat: {
        } break;
            
        case TurnTypeCreatureReproduce: {
        } break;
            
        case TurnTypeCreatureBorn: {
            animationPreparation = ^{
                [self createImageViewForCreature:turn.creature];
            };
        } break;
            
        case TurnTypeCreatureDie: {
            animationCompletion = ^{
                [self removeImageViewForCreature:turn.creature];
            };
        } break;
    }
    [Utils performOnMainThread:^{
        if (animationPreparation) {
            animationPreparation();
        }
        
        UIImageView *imageView = [self->_imageViewsDictionary objectForKey:turn.creature.uuid];
        [self->_animationController performAnimationsForTurn:turn
                                                    forLayer:imageView.layer
                                              withCompletion:^{
            if (turn.direction != DirectionNone) {
                turn.creature.direction = turn.direction;
            }
            if (animationCompletion) {
                animationCompletion();
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
