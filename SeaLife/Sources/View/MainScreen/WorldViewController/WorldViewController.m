//
//  WorldViewController.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "WorldViewController.h"

#import "Turn.h"
#import "WorldBackgroundView.h"
#import "World.h"
#import "WorldViewControllerDelegate.h"
#import "WorldDelegate.h"
#import "WorldProtocol.h"
#import "CreaturesView.h"
#import "WorldInfo.h"
#import "WorldPosition.h"

@interface WorldViewController ()
{
    id<WorldProtocol> _world;
}

@property (nonatomic) WorldBackgroundView *backgroundView;
@property (nonatomic) CreaturesView *creaturesView;

@end

@implementation WorldViewController

#pragma mark - Life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupBackground];

    [self setupCreaturesView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (_world) {
        [self redrawCreatureView];
    }
}

#pragma mark - Public

- (void)play
{
    if (!_world.isPlaying) {
        [_world play];
    }
}

- (void)stop
{
    if (_world.isPlaying) {
        [_world stop];
    }
}

- (void)reset
{
    [_world reset];
}

- (void)setAnimationSpeed:(float)animationSpeed
{
    [self.creaturesView setAnimationSpeed:animationSpeed];
}

- (void)createWorldWithInfo:(struct WorldInfo)worldInfo
{
    [_world stop];
    
    _world = [[World alloc] initWithInfo:worldInfo];
    _world.speed = self.creaturesSpeed;
    _world.delegate = self;
    _world.visualDelegate = self.creaturesView;
    
    self.backgroundView.sizeInCells = CGSizeMake(worldInfo.horizontalSize, worldInfo.verticalSize);
    [self.backgroundView setNeedsDisplay];

    [self.creaturesView reset];
    [self redrawCreatureView];

    [_world createInitialCreatures];
}

#pragma mark - Public Accessors

- (void)setCreaturesSpeed:(float)creaturesSpeed
{
    if (_creaturesSpeed == creaturesSpeed) { return; }
    [self willChangeValueForKey:@"creaturesSpeed"];
    _creaturesSpeed = creaturesSpeed;
    [self didChangeValueForKey:@"creaturesSpeed"];
    
    _world.speed = creaturesSpeed;
}

#pragma mark - WorldDelegate

- (void)worldDidFinishedWithReason:(WorldCompletionReason)reason
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(worldViewController:didCompleteWithReason:)]) {
        [self.delegate worldViewController:self
                     didCompleteWithReason:reason];
    }
}

#pragma mark - Private

- (void)redrawCreatureView
{
    CGFloat cellWidth = CGRectGetWidth(self.view.bounds) / _world.worldInfo.horizontalSize;
    CGFloat cellHeight = CGRectGetHeight(self.view.bounds) / _world.worldInfo.verticalSize;
    CGSize newCellSize = CGSizeMake(cellWidth, cellHeight);
    [self.creaturesView redrawToCellSize:newCellSize];
}

- (void)setupBackground
{
    self.backgroundView = [[WorldBackgroundView alloc] init];
    self.backgroundView.contentMode = UIViewContentModeRedraw;
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.backgroundView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.backgroundView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.backgroundView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.backgroundView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.backgroundView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)setupCreaturesView
{
    self.creaturesView = [[CreaturesView alloc] init];
    self.creaturesView.backgroundColor = UIColor.clearColor;
    self.creaturesView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.creaturesView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.creaturesView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.creaturesView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.creaturesView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.creaturesView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

#pragma mark - UIContentContainer

- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size
          withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (self->_world) {
            BOOL wasPlaying = self->_world.isPlaying;
            if (wasPlaying) { [self stop]; }
            [self redrawCreatureView];
            if (wasPlaying) { [self play]; }
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
    }];
}

@end
