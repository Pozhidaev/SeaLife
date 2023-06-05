//
//  Creature.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import "Creature.h"

#import "CreatureTimerProtocol.h"
#import "CreatureTimer.h"
#import "TurnHelperProtocol.h"
#import "TurnHelper.h"
#import "Turn.h"
#import "World.h"
#import "WorldCell.h"
#import "WorldProtocol.h"
#import "WorldVisualDelegate.h"
#import "CreatureFactory.h"
#import "CreatureProtocol.h"
#import "TurnType.h"
#import "WorldPosition.h"

@interface Creature ()
{
    id<CreatureTimerProtocol> _timer;
@protected Class _turnHelperClass;
    dispatch_queue_t _queue;
}
@property (nonatomic, readwrite) NSUUID *uuid;

@end

@implementation Creature

#pragma mark - Memory related

- (instancetype)init { assert(false); /*must call initWithTurnHelperClass*/ }

- (instancetype)initWithTurnHelperClass:(Class<TurnHelperProtocol>)turnHelperClass
{
    self = [super init];
    if (self) {
        self.uuid = [NSUUID UUID];
        _queue = dispatch_queue_create("CreatureQueue", 0);
        _turnHelperClass = turnHelperClass;
        
        __weak typeof(self) weakSelf = self;
        _timer = [[CreatureTimer alloc] initWithBlock:^{
            typeof(self) sSelf = weakSelf;
            if (!sSelf || sSelf.busy != NO) {
                return;
            }
            sSelf.busy = YES;
            dispatch_async(sSelf->_queue, ^{
                [sSelf performTurnWithCompletion:^{
                    sSelf.busy = NO;
                }];
            });
        }];
    }
    return self;
}

#pragma mark - CreatureProtocol

- (void)setTimerTargetQueue:(dispatch_queue_t)queue
{
    [_timer setTargetQueue:queue];
}

- (void)setSpeed:(float)speed
{
    [_timer setSpeed:speed];
}

- (void)start
{
    [_timer start];
}

- (void)pause
{
    [_timer pause];
}

- (void)stop
{
    [_timer stop];
    self.busy = YES;
}

#pragma mark - Private

- (void)performTurnWithCompletion:(void(^)(void))completion
{
    NSMutableSet<WorldCell *> *lockedCells;
    NSSet<WorldCell *> *posibleTurnCells;
    
    WorldCell *currentCell = [self.world cellForPosition:self.position];
    
    if (currentCell) {
        NSSet *turnPositions = [self possibleTurnPositionsFrom:self.position];
        posibleTurnCells = [self.world cellsForPositions:turnPositions];
        
        lockedCells = [posibleTurnCells mutableCopy];
        [lockedCells addObject:currentCell];
    }
    
    [self beforeEveryTurn];
    Turn *turn = [self decideTurnForCurrentCell:currentCell posibleCells:posibleTurnCells];
    assert(turn);
    [self afterEveryTurn];
    
    switch (turn.type) {
        case TurnTypeCreatureEmpty: {
            [self performEmpty:turn lockedCells:lockedCells completion:completion];
        } break;
        case TurnTypeCreatureMove: {
            [self performMove:turn lockedCells:lockedCells completion:completion];
        } break;
        case TurnTypeCreatureEat: {
            [self performEat:turn lockedCells:lockedCells completion:completion];
        } break;
        case TurnTypeCreatureReproduce: {
            [self performReproduce:turn lockedCells:lockedCells completion:completion];
        } break;
        case TurnTypeCreatureDie: {
            [self performDie:turn lockedCells:lockedCells completion:completion];
        } break;
        case TurnTypeCreatureBorn: { assert(false); //creature can't born itself
        } break;
    }
}

- (void)beforeEveryTurn { assert(false); /*must be overriden*/ }
- (void)afterEveryTurn { assert(false); /*must be overriden*/ }
- (NSSet<NSValue *> *)possibleTurnPositionsFrom:(struct WorldPosition)position
{ assert(false); /*must be overriden*/ return nil; }
- (Turn *)decideTurnForCurrentCell:(WorldCell *)currentCell
                      posibleCells:( NSSet<WorldCell *> *)posibleCells
{ assert(false); /*must be overriden*/ }

#pragma mark - Private

- (void)performEmpty:(Turn *)turn
         lockedCells:(NSMutableSet<WorldCell *> *)lockedCells
          completion:(void(^)(void))completion
{
    [self.world unlockCells:lockedCells];
    [self.visualDelegate performAnimationsForTurn:turn
                                   withCompletion:^{
        completion();
    } completionQueue:_queue];
}

- (void)performDie:(Turn *)turn
       lockedCells:(NSMutableSet<WorldCell *> *)lockedCells
        completion:(void(^)(void))completion
{
    [lockedCells removeObject:turn.cell];
    
    [self.world unlockCells:lockedCells];
    
    __weak id<WorldProtocol> wWorld = self.world;
    [self.visualDelegate performAnimationsForTurn:turn
                                   withCompletion:^{
        [wWorld removeCreature:turn.creature
                        atCell:turn.cell];
        [wWorld unlockCell:turn.cell];
        
        completion();
    } completionQueue:_queue];
}

- (void)performMove:(Turn *)turn
        lockedCells:(NSMutableSet<WorldCell *> *)lockedCells
         completion:(void(^)(void))completion
{
    [self.world moveCreature:self
                    fromCell:turn.cell
                      toCell:turn.targetCell];
    
    [lockedCells removeObject:turn.targetCell];
    [self.world unlockCells:lockedCells];
    
    __weak id<WorldProtocol> wWorld = self.world;
    [self.visualDelegate performAnimationsForTurn:turn
                                   withCompletion:^{
        [wWorld unlockCell:turn.targetCell];
        
        completion();
    } completionQueue:_queue];
}

- (void)performReproduce:(Turn *)turn
             lockedCells:(NSMutableSet<WorldCell *> *)lockedCells
              completion:(void(^)(void))completion
{
    [lockedCells removeObject:turn.cell];
    [lockedCells removeObject:turn.targetCell];
    [self.world unlockCells:lockedCells];
    
    __weak id<WorldProtocol> wWorld = self.world;
    [self.visualDelegate performAnimationsForTurn:turn
                                   withCompletion:^{
        [wWorld unlockCell:turn.cell];
        id<CreatureProtocol> newCreature = [CreatureFactory creatureFromCreature:self];
        newCreature.busy = YES;
        [self.world addCreature:newCreature
                         atCell:turn.targetCell];
        Turn *nextTurn = [Turn bornTurnWithCreature:newCreature
                                        currentCell:turn.targetCell];
        completion();
        [self.visualDelegate performAnimationsForTurn:nextTurn
                                       withCompletion:^(){
            [wWorld unlockCell:turn.targetCell];
            [newCreature start];
            newCreature.busy = NO;
        } completionQueue:self->_queue];
    }  completionQueue:_queue];
}

- (void)performEat:(Turn *)turn
       lockedCells:(NSMutableSet<WorldCell *> *)lockedCells
        completion:(void(^)(void))completion
{
    id<CreatureProtocol> targetCreature = [turn.otherCreatures anyObject];
    
    [targetCreature stop];
    [self.world removeCreature:targetCreature
                        atCell:turn.targetCell];
    [self.world moveCreature:self
                    fromCell:turn.cell
                      toCell:turn.targetCell];
    
    [lockedCells removeObject:turn.targetCell];
    [self.world unlockCells:lockedCells];
    
    __weak id<WorldProtocol> wWorld = self.world;
    [self.visualDelegate performAnimationsForTurn:turn
                                   withCompletion:^{
        Turn *nextTurn = [Turn dieTurnWithCreature:targetCreature
                                       currentCell:turn.targetCell];
        [wWorld unlockCell:turn.targetCell];
        [self.visualDelegate performAnimationsForTurn:nextTurn
                                       withCompletion:^{
        } completionQueue:self->_queue];
        
        completion();
    } completionQueue:_queue];
}

#pragma mark - Public

- (NSString *)debugDescription
{
    return [self debugDescriptionIndent:0
                                caption:@"\n======= Creature =======\n"];
}

- (NSString *)debugDescriptionIndent:(NSInteger)indent
                             caption:(NSString *)caption
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:caption];
    
    NSMutableString *indentString = [[NSMutableString alloc] init];
    for (int i = 0; i < indent; i++) { [indentString appendString:@" "]; }
    
    [description appendFormat:@"%@uuid :: %@\n", indentString, self.uuid];
    [description appendFormat:@"%@position :: { x: %li, y: %li}\n", indentString, (long)self.position.x, (long)self.position.y];
    [description appendFormat:@"%@direction :: %li", indentString, (long)self.direction];
    
    return description;
}

#pragma mark - All Turns

- (Turn *)tryMoveFromCell:(WorldCell *)currentCell
            possibleCells:(NSSet<WorldCell *> *)possibleCells
{
    MoveRuleFunction filterFunction = [_turnHelperClass moveRuleFunction];
    WorldCell *targetCell = [_turnHelperClass cellFromCells:possibleCells
                                         withFilterFunction:filterFunction];
    if (!targetCell) {
        return nil;
    }
    return [Turn moveTurnWithCreature:self
                          currentCell:currentCell
                           targetCell:targetCell];
}

- (Turn *)tryEatFromCell:(WorldCell *)currentCell
           possibleCells:(NSSet<WorldCell *> *)possibleCells
{
    MoveRuleFunction filterFunction = [_turnHelperClass eatingRuleFunction];
    WorldCell *targetCell = [_turnHelperClass cellFromCells:possibleCells
                                         withFilterFunction:filterFunction];
    if (!targetCell) {
        return nil;
    }
    return [Turn eatTurnWithCreature:self
                         currentCell:currentCell
                          targetCell:targetCell
                       otherCreature:targetCell.creature];
}

- (Turn *)tryReproduceFromCell:(WorldCell *)currentCell
                 possibleCells:(NSSet<WorldCell *> *)possibleCells
{
    MoveRuleFunction filterFunction = [_turnHelperClass reproduceRuleFunction];
    WorldCell *targetCell = [_turnHelperClass cellFromCells:possibleCells
                                         withFilterFunction:filterFunction];
    if (!targetCell) {
        return nil;
    }
    return [Turn reproduceTurnWithCreature:self
                               currentCell:currentCell
                                targetCell:targetCell];
}

@end
