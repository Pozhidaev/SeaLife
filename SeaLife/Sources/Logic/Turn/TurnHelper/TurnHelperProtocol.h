//
//  TurnHelperProtocol.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 12.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;
@class WorldCell;
struct WorldPosition;

typedef NSSet *_Nullable(^PositionsRuleFunction)(struct WorldPosition);
typedef BOOL (^MoveRuleFunction)(WorldCell *_Nullable cell);

NS_ASSUME_NONNULL_BEGIN

@protocol TurnHelperProtocol <NSObject>

//Cells
+ (WorldCell * _Nullable)cellFromCells:(NSSet<WorldCell *> *)cells
          withFilterFunction:(BOOL(^)(WorldCell *cell))filterRule;

//Move blocks
+ (PositionsRuleFunction)upMoveRule;
+ (PositionsRuleFunction)downMoveRule;
+ (PositionsRuleFunction)leftMoveRule;
+ (PositionsRuleFunction)rightMoveRule;

+ (PositionsRuleFunction)positionsRuleForMove;
+ (PositionsRuleFunction)positionsRuleForReproduce;
+ (PositionsRuleFunction)positionsRuleForEat;

//filter
+ (MoveRuleFunction)moveRuleFunction;
+ (MoveRuleFunction)eatingRuleFunction;
+ (MoveRuleFunction)reproduceRuleFunction;

@end

NS_ASSUME_NONNULL_END
