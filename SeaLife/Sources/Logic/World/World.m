//
//  WorldLogicController.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "World.h"

#import "WorldCell.h"
#import "CreatureFactory.h"
#import "CreatureProtocol.h"
#import "WorldProtocol.h"
#import "WorldDelegate.h"
#import "WorldVisualDelegate.h"
#import "WorldCompletionReason.h"
#import "WorldInfo.h"
#import "WorldPosition.h"
#import "NSValue+WorldPosition.h"

@interface World()
{
    NSMutableSet<WorldCell *> *_lockedCells;
    
    NSRecursiveLock *_lockedCellsLock;
    NSRecursiveLock *_creaturesLock;
    NSRecursiveLock *_cellsLock;
    
    NSMutableSet<id<CreatureProtocol>> *_creatures;
    NSArray<WorldCell *> *_cells;
}

@property (nonatomic, readwrite) struct WorldInfo worldInfo;
@property (nonatomic, readwrite) BOOL isPlaying;

@end

@implementation World

#pragma mark - Memory related

- (instancetype)initWithInfo:(struct WorldInfo)worldInfo
{
    self = [super init];
    if (self) {
        self.worldInfo = worldInfo;
        self.isPlaying = NO;
        self.speed = 0;
        
        _creatures = [[NSMutableSet alloc] init];
  
        _lockedCellsLock = [[NSRecursiveLock alloc] init];
        _creaturesLock = [[NSRecursiveLock alloc] init];
        _cellsLock = [[NSRecursiveLock alloc] init];
        
        _lockedCells = [[NSMutableSet alloc] init];
        
        _cells = [self createCellsForXSize:_worldInfo.horizontalSize
                                     ySize:_worldInfo.verticalSize];
    }
    return self;
}

#pragma mark - Public methods

- (void)play
{
    [_creaturesLock lock];
    [_creatures makeObjectsPerformSelector:@selector(start)];
    [_creaturesLock unlock];
    
    self.isPlaying = YES;
    [self.visualDelegate play];
}

- (void)stop
{
    [_creaturesLock lock];
    [_creatures makeObjectsPerformSelector:@selector(pause)];
    [_creaturesLock unlock];

    self.isPlaying = NO;
    [self.visualDelegate stop];
}

- (void)reset
{
    [self stop];

    [_creatures removeAllObjects];
    [_lockedCells removeAllObjects];

    [self.visualDelegate reset];
    
    for (WorldCell *cell in _cells) {
        cell.creature = nil;
    }
    
    [self createInitialCreatures];
}

#pragma mark - Accessors

- (void)setSpeed:(float)speed
{
    if (_speed == speed) { return; }
    [self willChangeValueForKey:@"speed"];
    _speed = speed;
    [self didChangeValueForKey:@"speed"];
    
    [_creaturesLock lock];
    for (id<CreatureProtocol> creture in _creatures) {
        [creture setSpeed:_speed];
    }
    [_creaturesLock unlock];
}

#pragma mark - Private

- (NSArray<WorldCell *> *)createCellsForXSize:(NSInteger)xSize
                                        ySize:(NSInteger)ySize
{
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:ySize * xSize];
    for (int i = 0; i < xSize * ySize; i++) {
        WorldPosition position = {.x = i % self.worldInfo.horizontalSize, .y = i / self.worldInfo.horizontalSize};
        WorldCell *cell = [[WorldCell alloc] initWithPosition:position];
        [cells addObject:cell];
    }
    return [cells copy];
}

#pragma mark - WorldProtocol methods

- (void)addCreature:(id<CreatureProtocol>)creature
             atCell:(WorldCell *)cell
{
    assert(cell);
    assert(cell.creature == nil);

    creature.position = cell.position;
    [creature setSpeed:_speed];
   
    [_cellsLock lock];
    cell.creature = creature;
    [_cellsLock unlock];
    
    [_creaturesLock lock];
    [_creatures addObject:creature];
    [_creaturesLock unlock];
}

- (void)removeCreature:(id<CreatureProtocol>)creature
                atCell:(WorldCell *)cell
{
    [_creaturesLock lock];
    [_creatures removeObject:creature];
    [_creaturesLock unlock];

    assert(cell);

    [_cellsLock lock];
    cell.creature = nil;
    [_cellsLock unlock];

    if ([_creatures count] == 0) {
        [self stop];
        [self.delegate worldDidFinishedWithReason:WorldCompletionReasonEmpty];
    }
}

- (void)moveCreature:(id<CreatureProtocol>)creature
            fromCell:(WorldCell *)fromCell
              toCell:(WorldCell *)toCell
{
    [_cellsLock lock];
    toCell.creature = creature;
    fromCell.creature = nil;
    creature.position = toCell.position;
    [_cellsLock unlock];
}

- (WorldCell *)cellForPosition:(struct WorldPosition)position
{
    NSSet *positionSet = [NSSet setWithObject:[NSValue valueWithWorldPosition:position]];
    return [[self cellsForPositions:positionSet] anyObject];
}

- (NSSet<WorldCell *> *)cellsForPositions:(NSSet<NSValue *> *)positions
{
    NSMutableSet<WorldCell *> *cells;
    
    [_lockedCellsLock lock]; {
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        for (NSValue *positionValue in positions) {
            WorldPosition position = [positionValue worldPositionValue];
            if ((position.x >= 0 && position.x < _worldInfo.horizontalSize) &&
                (position.y >= 0 && position.y < _worldInfo.verticalSize)) {
                [indexSet addIndex:position.y * self.worldInfo.horizontalSize + position.x];
            }
        }
        
        cells = [[NSMutableSet alloc] initWithArray:[_cells objectsAtIndexes:indexSet]];
        
        [cells minusSet:_lockedCells];
        
        [self lockCells:cells];
    } [_lockedCellsLock unlock];

    return [cells copy];
}

- (void)lockCell:(WorldCell *)cell
{
    [self lockCells:[NSSet setWithObject:cell]];
}

- (void)lockCells:(NSSet<WorldCell *> *)cells
{
    [_lockedCellsLock lock];
    [_lockedCells addObjectsFromArray:[cells allObjects]];
    [_lockedCellsLock unlock];
}

- (void)unlockCell:(WorldCell *)cell
{
    [self unlockCells:[NSSet setWithObject:cell]];
}

- (void)unlockCells:(NSSet<WorldCell *> *)cells
{
    [_lockedCellsLock lock];
    for (WorldCell *cell in cells) {
        [_lockedCells removeObject:cell];
    }
    [_lockedCellsLock unlock];
}

- (void)createInitialCreatures
{
    //for testing
//    id<CreatureProtocol> creature1 = [CreatureFactory fishCreatureForWorld:self
//                                                            visualDelegate:self.visualDelegate];
//    [self addCreature:creature1 atCell:[self cellForPosition:(struct WorldPosition){.x = 0, .y = 10}]];
//    id<CreatureProtocol> creature2 = [CreatureFactory orcaCreatureForWorld:self
//                                                            visualDelegate:self.visualDelegate];
//    [self addCreature:creature2 atCell:[self cellForPosition:(struct WorldPosition){.x = 5, .y = 10}]];
//    return;
    
    NSMutableArray *creatures = [[NSMutableArray alloc] initWithCapacity:self.worldInfo.fishCount + self.worldInfo.orcaCount];
    for (int i = 0; i < self.worldInfo.fishCount; i++) {
        id<CreatureProtocol> creature = [CreatureFactory fishCreatureForWorld:self
                                                               visualDelegate:self.visualDelegate];
        [creatures addObject:creature];
    }
    for (int i = 0; i < self.worldInfo.orcaCount; i++) {
        id<CreatureProtocol> creature = [CreatureFactory orcaCreatureForWorld:self
                                                               visualDelegate:self.visualDelegate];
        [creatures addObject:creature];
    }

    NSMutableArray *freeCells = [[NSMutableArray alloc] initWithArray:_cells];
    for (id<CreatureProtocol> creature in creatures) {
        NSInteger randomIndex = (NSInteger)arc4random_uniform((int)freeCells.count);
        WorldCell *cell = freeCells[randomIndex];
        [freeCells removeObjectAtIndex:randomIndex];
                               
        [self addCreature:creature atCell:cell];
    }
    
    [self.visualDelegate createImageViewForCreatures:_creatures];
}

@end
