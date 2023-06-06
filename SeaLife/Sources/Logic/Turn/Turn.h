//
//  Turn.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright (c) 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Direction);
typedef NS_ENUM(NSInteger, TurnType);

@protocol CreatureProtocol;
@class WorldCell;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface Turn : NSObject

@property (nonatomic, readonly) TurnType type;
@property (nonatomic, readonly) id<CreatureProtocol> creature;
@property (nonatomic, readonly, weak) WorldCell *cell;
@property (nonatomic, readonly, nullable) NSHashTable<WorldCell *> *otherCells;
@property (nonatomic, readonly, nullable) NSHashTable<id<CreatureProtocol>> *otherCreatures;

+ (instancetype)emptyTurnWithCreature:(id<CreatureProtocol>)creture
                          currentCell:(WorldCell *_Nullable)currentCell;

+ (instancetype)bornTurnWithCreature:(id<CreatureProtocol>)creture
                         currentCell:(WorldCell *)currentCell;

+ (instancetype)dieTurnWithCreature:(id<CreatureProtocol>)creture
                        currentCell:(WorldCell *)currentCell;

+ (instancetype)moveTurnWithCreature:(id<CreatureProtocol>)creture
                          currentCell:(WorldCell *)currentCell
                          targetCell:(WorldCell *)targetCell;

+ (instancetype)eatTurnWithCreature:(id<CreatureProtocol>)creture
                        currentCell:(WorldCell *)currentCell
                         targetCell:(WorldCell *)targetCell
                      otherCreature:(id<CreatureProtocol>)otherCreture;

+ (instancetype)reproduceTurnWithCreature:(id<CreatureProtocol>)creture
                              currentCell:(WorldCell *)currentCell
                               targetCell:(WorldCell *)targetCell;

- (Direction)direction;
- (WorldCell *_Nullable)targetCell;
- (struct WorldPosition)finalPosition;
- (NSSet<WorldCell*> *)usedCells;

- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
