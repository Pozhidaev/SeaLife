//
//  FishCreature.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "FishCreature.h"

#import "Turn.h"
#import "WorldCell.h"

#import "TurnHelperProtocol.h"
#import "Creature+Private.h"

#import "Direction.h"
#import "WorldPosition.h"

@interface FishCreature()
{
    NSInteger _reproductivePoints;
}

@end

@implementation FishCreature

#pragma mark - Initializer

- (instancetype)initWithTurnHelperClass:(Class<TurnHelperProtocol>)turnHelperClass
{
    self = [super initWithTurnHelperClass:turnHelperClass];
    if (self) {
        self.direction = DirectionRight;
    }
    return self;
}

#pragma mark - Public

- (void)beforeEveryTurn
{
    _reproductivePoints += 1;
}
- (void)afterEveryTurn
{
    if (_reproductivePoints >= kFishReproductionPeriod) {
        _reproductivePoints = 0;
    }
}

- (NSSet<NSValue *> *)possibleTurnPositionsFrom:(struct WorldPosition)position
{
//    return [self.turnHelperClass rightMoveRule](position); // for testing
    NSSet *movePositions = [_turnHelperClass positionsRuleForMove](position);
    NSSet *reproducePositions = [_turnHelperClass positionsRuleForReproduce](position);
    return [movePositions setByAddingObjectsFromSet:reproducePositions];
}

- (Turn *)decideTurnForCurrentCell:(WorldCell *)currentCell
                      posibleCells:( NSSet<WorldCell *> *)possibleCells
{
    Turn *turn = nil;
    
    //try reproduce
    if (!turn) {
        if (_reproductivePoints >= kFishReproductionPeriod) {
            turn = [self tryReproduceFromCell:currentCell
                                possibleCells:possibleCells];
        }
    }
    //try move
    if (!turn) {
        turn = [self tryMoveFromCell:currentCell
                       possibleCells:possibleCells];
    }
    //empty
    if (!turn) {
        turn = [Turn emptyTurnWithCreature:self
                               currentCell:currentCell];
    }
    
    return turn;
}

@end
