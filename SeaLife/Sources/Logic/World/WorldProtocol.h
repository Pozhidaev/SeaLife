//
//  WorldProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;
@protocol WorldDelegate;
@protocol WorldVisualDelegate;
@class WorldCell;
@class Turn;
struct WorldInfo;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@protocol WorldProtocol <NSObject>

@property (nonatomic, readonly, assign) struct WorldInfo worldInfo;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic) float speed;

@property (nonatomic, weak) id<WorldDelegate> delegate;
@property (nonatomic, weak, nullable) id<WorldVisualDelegate> visualDelegate;

- (instancetype)initWithInfo:(struct WorldInfo)worldInfo;

- (void)play;
- (void)stop;
- (void)reset;

//creatures
- (void)createInitialCreatures;
- (void)addCreature:(id<CreatureProtocol>)creature atCell:(WorldCell *)cell;
- (void)removeCreature:(id<CreatureProtocol>)creature atCell:(WorldCell *)cell;
- (void)moveCreature:(id<CreatureProtocol>)creature fromCell:(WorldCell *)fromCell toCell:(WorldCell *)toCell;

//cells
- (WorldCell *)cellForPosition:(struct WorldPosition)position;
- (NSSet<WorldCell *> *)cellsForPositions:(NSSet<NSValue *> *)positions;

- (void)unlockCell:(WorldCell *)cell;
- (void)unlockCells:(NSSet<WorldCell *> *)cells;

@end

NS_ASSUME_NONNULL_END
