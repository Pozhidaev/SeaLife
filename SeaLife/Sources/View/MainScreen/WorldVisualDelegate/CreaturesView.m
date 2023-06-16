//
//  CreaturesView.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreaturesView.h"
#import "UIImage+Creature.h"
#import "CreatureAnimator.h"
#import "CreatureProtocol.h"
#import "WorldPosition.h"

@interface CreaturesView()
{
    NSMapTable *_animators;
    float _animationSpeed;
    CGSize _cellSize;
}

@end

@implementation CreaturesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPointerFunctionsOptions keyOptions = NSPointerFunctionsWeakMemory;
        NSPointerFunctionsOptions valueOptions = NSPointerFunctionsWeakMemory;
        _animators = [[NSMapTable alloc] initWithKeyOptions:keyOptions valueOptions:valueOptions capacity:0];
        _animationSpeed = 0.0;
        _cellSize = CGSizeZero;
    }
    return self;
}

#pragma mark - WorldVisualDelegate

- (void)reset
{
    [_animators removeAllObjects];
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    if (_animationSpeed == animationSpeed) { return; }
    
    _animationSpeed = animationSpeed;

    for (CreatureAnimator *animator in _animators.objectEnumerator) {
        animator.animationSpeed = animationSpeed;
    }
}

- (void)redrawToCellSize:(CGSize)toCellSize
{
    CGSize fromCellSize = CGSizeEqualToSize(_cellSize, CGSizeZero) == NO ? _cellSize : toCellSize;
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
    
    for (CreatureAnimator *animator in _animators.objectEnumerator) {
        animator.cellSize = toCellSize;
    }
    
    _cellSize = toCellSize;
}

- (void)addCreature:(id<CreatureProtocol>)creature at:(struct WorldPosition)position
{
    UIImageView *visualComponent = [self visualComponentForCreatureClass:creature.class];
    visualComponent.center = CGPointMake(_cellSize.width * (position.x + 0.5),
                                         _cellSize.height * (position.y + 0.5));
    [self addSubview:visualComponent];
    
    CreatureAnimator *animator = [[CreatureAnimator alloc] init];
    animator.visualComponent = visualComponent;
    
    [self addAnimator:animator for:creature.uuid];
    
    creature.animator = animator;
}

- (void)removeCreature:(id<CreatureProtocol>)creature
{
    [creature.animator.visualComponent removeFromSuperview];
    
    [_animators removeObjectForKey:creature.uuid];
}

#pragma mark - Private methods

- (UIImageView *)visualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass
{
    UIImage *image = [UIImage imageFor:creatureClass];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(_cellSize.width, _cellSize.height);

    CGFloat delta = 0;
    if (frame.size.width > kCreatureImageViewMinSizeForReducing) {
        delta = frame.size.width * kCreatureImageViewReducingCoeficient;
    }
    imageView.frame = CGRectInset(frame, delta, delta);
    
    return imageView;
}

- (void)addAnimator:(CreatureAnimator *)animator for:(NSUUID *)creatureUUID
{
    animator.cellSize = _cellSize;
    animator.animationSpeed = _animationSpeed;
    
    [_animators setObject:animator forKey:creatureUUID];
}


@end
