//
//  OrcaCreature.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "OrcaCreature.h"

#import "Creature+Private.h"
#import "Turn.h"
#import "TurnHelperProtocol.h"
#import "Direction.h"
#import "WorldCell.h"
#import "WorldPosition.h"

@interface OrcaCreature()
{
    NSInteger _hungerPoints;
    NSInteger _reproductivePoints;
}

@end

@implementation OrcaCreature

#pragma mark - Initializer

- (instancetype)initWithDeps:(CreatureDeps *)deps
{
    self = [super initWithDeps: deps];
    if (self) {
        _hungerPoints = kOrcaAllowedHungerPoins;
        _reproductivePoints = 0;
        self.direction = DirectionRight;
    }
    return self;
}

#pragma mark - Public

- (void)beforeEveryTurn
{
    _reproductivePoints += 1;
    _hungerPoints -= 1;
    
    if (_hungerPoints < 0) {
        self.live = NO;
    }
}
- (void)afterEveryTurn
{
    if (_reproductivePoints >= kOrcaReproductionPeriod) {
        _reproductivePoints = 0;
    }
}

- (Turn *)decideTurnForCurrentCell:(WorldCell *)currentCell
                      posibleCells:(NSSet<WorldCell *> *)possibleCells
{
    if (self.live == NO) {
        return [Turn dieTurnWithCreature:self
                             currentCell:currentCell];
    }

    if (!currentCell) {
        return [Turn emptyTurnWithCreature:self
                               currentCell:nil];
    }
    
    Turn *turn = nil;

    //try reproduce
    if (!turn) {
        if (_reproductivePoints >= kOrcaReproductionPeriod) {
            turn = [self tryReproduceFromCell:currentCell
                                possibleCells:possibleCells];
        }
    }
    //try eat
    if (!turn) {
        turn = [self tryEatFromCell:currentCell
                      possibleCells:possibleCells];
        if (turn) {
            _hungerPoints = kOrcaAllowedHungerPoins;
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
