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
    NSPointerArray *_animatorsArray;
    float _animationSpeed;
    CGSize _cellSize;
}

@end

@implementation CreaturesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSPointerFunctionsOptions options = NSPointerFunctionsWeakMemory;
        _animatorsArray = [[NSPointerArray alloc] initWithOptions:options];
        _animationSpeed = 0.0;
        _cellSize = CGSizeZero;
    }
    return self;
}

#pragma mark - Accessors

- (void)setCellSize:(CGSize)cellSize
{
    if (CGSizeEqualToSize(_cellSize, cellSize)) { return; }

    _cellSize = cellSize;

    for (CreatureAnimator *animator in _animatorsArray.allObjects) {
        animator.cellSize = cellSize;
    }
}

#pragma mark - WorldVisualDelegate

- (void)reset
{
    for (int i = 0; i < _animatorsArray.count; i++) {
        [_animatorsArray removePointerAtIndex:i];
    }
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)addAnimator:(CreatureAnimator *)animator
{
    animator.cellSize = _cellSize;
    animator.animationSpeed = _animationSpeed;
    [_animatorsArray addPointer:(__bridge void *)(animator)];
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    if (_animationSpeed == animationSpeed) { return; }
    
    _animationSpeed = animationSpeed;

    for (CreatureAnimator *animator in _animatorsArray.allObjects) {
        animator.animationSpeed = animationSpeed;
    }
}

- (void)placeVisualComponentOfCreature:(id<CreatureProtocol>)creature
                                    at:(struct WorldPosition)position
{
    creature.animator.cellSize = _cellSize;
    creature.animator.animationSpeed = _animationSpeed;
    [_animatorsArray addPointer:(__bridge void *)(creature.animator)];
    
    UIImageView *visualComponent = creature.animator.visualComponent;
    visualComponent.center = CGPointMake(_cellSize.width * (position.x + 0.5),
                                         _cellSize.height * (position.y + 0.5));
    [self addSubview:visualComponent];
}

- (void)removeVisualComponentOfCreature:(id<CreatureProtocol>)creature
{
    [creature.animator.visualComponent removeFromSuperview];
}

- (UIImageView *)createVisualComponentForCreatureClass:(Class<CreatureProtocol>)creatureClass
{
    UIImage *image = [UIImage imageFor:creatureClass];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tintColor = [UIColor colorNamed:@"CreaturesTintColor"];
    CGRect frame = CGRectZero;
    frame.size = CGSizeMake(_cellSize.width, _cellSize.height);

    CGFloat delta = 0;
    if (frame.size.width > kCreatureImageViewMinSizeForReducing) {
        delta = frame.size.width * kCreatureImageViewReducingCoeficient;
    }
    imageView.frame = CGRectInset(frame, delta, delta);
    
    return imageView;
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
    
    [self setCellSize:toCellSize];
}

@end
