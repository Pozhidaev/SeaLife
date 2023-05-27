//
//  WorldLogicController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WorldProtocol.h"

@protocol CreatureProtocol;
@protocol WorldProtocol;
@protocol WorldDelegate;
@protocol WorldVisualDelegate;
@class WorldCell;
struct WorldInfo;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface World : NSObject<WorldProtocol>

@property (nonatomic, readonly) struct WorldInfo worldInfo;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic) float speed;

@property (nonatomic, weak) id<WorldDelegate> delegate;
@property (nonatomic, weak, nullable) id<WorldVisualDelegate> visualDelegate;

- (instancetype)initWithInfo:(struct WorldInfo)worldInfo;

- (void)play;
- (void)stop;
- (void)reset;
- (void)prepare;

//creatures
- (void)addCreature:(id<CreatureProtocol>)creature atCell:(WorldCell *)cell;
- (void)removeCreature:(id<CreatureProtocol>)creature atCell:(WorldCell *)cell;;
- (void)moveCreature:(id<CreatureProtocol>)creature fromCell:(WorldCell *)fromCell toCell:(WorldCell *)toCell;

//cells
- (WorldCell *)cellForPosition:(struct WorldPosition)position;
- (NSSet<WorldCell *> *)cellsForPositions:(NSSet<NSValue *> *)positions;

- (void)unlockCell:(WorldCell *)cell;
- (void)unlockCells:(NSSet<WorldCell *> *)cells;

@end

NS_ASSUME_NONNULL_END
