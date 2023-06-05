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
}

@property (nonatomic) CGSize cellSize;

@end


@implementation CreaturesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _animationController = [[AnimationsController alloc] init];

        self.cellSize = CGSizeZero;
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
    [_animationController reset];

    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    _animationController.animationSpeed = animationSpeed;
}

- (void)placeVisualComponent:(UIImageView *)visualComponent
                 forCreature:(id<CreatureProtocol>)creature
                          at:(struct WorldPosition)position
{
    visualComponent.center = CGPointMake(self.cellSize.width * (position.x + 0.5),
                                         self.cellSize.height * (position.y + 0.5));
    [self addSubview:visualComponent];
}

- (UIImageView *)visualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass
{
    UIImage *image = [UIImage imageFor:creatureClass];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor colorNamed:@"CreaturesTintColor"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(self.cellSize.width, self.cellSize.height);

    CGFloat delta = 0;
    if (frame.size.width > kCreatureImageViewMinSizeForReducing) {
        delta = frame.size.width * kCreatureImageViewReducingCoeficient;
    }
    imageView.frame = CGRectInset(frame, delta, delta);
    
    return imageView;
}

- (void)removeVisualComponentForCreature:(id<CreatureProtocol>)creature
{
    assert(creature);
    [creature.visualComponent removeFromSuperview];
    [_animationController removeAllAnimationsForCreatureUUID:creature.uuid];
}

- (void)redrawToCellSize:(CGSize)toCellSize
{
    CGSize fromCellSize = CGSizeEqualToSize(self.cellSize, CGSizeZero) == NO ? self.cellSize : toCellSize;
    CGFloat xCoeficient = toCellSize.width / fromCellSize.width;
    CGFloat yCoeficient = toCellSize.height / fromCellSize.height;
    
    for (UIView *view in self.subviews) {
        CGRect bounds = view.bounds;
        bounds.size = CGSizeMake(bounds.size.width * xCoeficient, bounds.size.height * yCoeficient);
        view.bounds = bounds;
        CGPoint center = view.center;
        center = CGPointMake(center.x * xCoeficient, center.y * yCoeficient);
        view.center = center;
    }
    
    self.cellSize = toCellSize;
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
                [self placeVisualComponent:turn.creature.visualComponent
                               forCreature:turn.creature
                                        at:turn.creature.position];
            };
        } break;
            
        case TurnTypeCreatureDie: {
            animationCompletion = ^{
                [self removeVisualComponentForCreature:turn.creature];
            };
        } break;
    }
    [Utils performOnMainThread:^{
        if (animationPreparation) {
            animationPreparation();
        }
        
        CALayer *layer = turn.creature.visualComponent.layer;
        [self->_animationController performAnimationsForTurn:turn
                                                    forLayer:layer
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
