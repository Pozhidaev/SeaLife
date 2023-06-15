//
//  FishCreature.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "FishCreature.h"

#import "Creature+Private.h"
#import "Turn.h"
#import "TurnHelperProtocol.h"
#import "Direction.h"
#import "WorldCell.h"
#import "WorldPosition.h"

@interface FishCreature()
{
    NSInteger _reproductivePoints;
}

@end

@implementation FishCreature

#pragma mark - Initializer

- (instancetype)initWithDeps:(CreatureDeps *)deps
{
    self = [super initWithDeps: deps];
    if (self) {
        _reproductivePoints = 0;
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
