//
//  CreaturesView.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 16.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "CreaturesView.h"
#import "UIImage+Creature.h"
#import "AnimationsController.h"
#import "CreatureProtocol.h"
#import "WorldPosition.h"

@interface CreaturesView()
{
    NSPointerArray *_animatorsArray;
    float _animationSpeed;
}

@property (nonatomic) CGSize cellSize;

@end

@implementation CreaturesView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cellSize = CGSizeZero;
        NSPointerFunctionsOptions options = NSPointerFunctionsWeakMemory;
        _animatorsArray = [[NSPointerArray alloc] initWithOptions:options];
        _animationSpeed = 0.0;
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

    for (AnimationsController *animator in _animatorsArray.allObjects) {
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

- (void)addAnimator:(AnimationsController *)animator
{
    animator.cellSize = self.cellSize;
    animator.animationSpeed = _animationSpeed;
    [_animatorsArray addPointer:(__bridge void *)(animator)];
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    if (_animationSpeed == animationSpeed) { return; }
    
    _animationSpeed = animationSpeed;

    for (AnimationsController *animator in _animatorsArray.allObjects) {
        animator.animationSpeed = animationSpeed;
    }
}

- (void)placeVisualComponent:(UIImageView *)visualComponent
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

@end
