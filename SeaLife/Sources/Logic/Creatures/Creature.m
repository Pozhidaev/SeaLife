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
#import "TurnType.h"

#import "WorldProtocol.h"
#import "World.h"
#import "WorldCell.h"
#import "WorldPosition.h"

#import "CreatureProtocol.h"
#import "CreatureAnimator.h"
#import "CreatureDeps.h"

@interface Creature ()
{
    id<CreatureTimerProtocol> _timer;
@protected Class _turnHelperClass;
    dispatch_queue_t _queue;
    __weak id<WorldProtocol> _world;
}
@property (nonatomic, readwrite) NSUUID *uuid;
@property (nonatomic, readwrite) CreatureAnimator *animator;

@end

@implementation Creature

#pragma mark - Memory related

- (instancetype)init { assert(false); /*must call initWithTurnHelperClass*/ }

- (instancetype)initWithDeps:(CreatureDeps *)deps
{
    self = [super init];
    if (self) {
        self.uuid = [NSUUID UUID];
        self.busy = NO;
        self.animator = deps.animator;

        _queue = dispatch_queue_create("creature_private_queue", DISPATCH_QUEUE_SERIAL_INACTIVE);
        dispatch_set_target_queue(_queue, deps.creaturesParentQueue);
        dispatch_activate(_queue);
        
        _turnHelperClass = deps.turnHelperClass;
        _world = deps.world;
        
        __weak typeof(self) weakSelf = self;
        _timer = [[CreatureTimer alloc] initWithTargetQueue:deps.timersParentQueue
                                                      block: ^{
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

- (void)setSpeed:(float)speed
{
    [_timer setSpeed:speed];
}

- (void)start
{
    [_timer start];
    [_animator play];
}

- (void)pause
{
    [_timer pause];
    [_animator pause];
}

- (void)stop
{
    self.busy = YES;
    [_timer stop];
}

#pragma mark - Private

- (void)performTurnWithCompletion:(void(^)(void))completion
{
    NSMutableSet<WorldCell *> *lockedCells;
    NSSet<WorldCell *> *posibleTurnCells;
    
    WorldCell *currentCell = [_world cellForPosition:self.position];
    
    if (currentCell) {
        NSSet *turnPositions = [_turnHelperClass possibleTurnPositionsFrom:self.position];
        posibleTurnCells = [_world cellsForPositions:turnPositions];
        
        lockedCells = [posibleTurnCells mutableCopy];
        [lockedCells addObject:currentCell];
    }
    
    [self beforeEveryTurn];
    Turn *turn = [self decideTurnForCurrentCell:currentCell posibleCells:posibleTurnCells];
    assert(turn);
    [self afterEveryTurn];
    
    [lockedCells minusSet:turn.usedCells];
    [_world unlockCells:lockedCells];
    
    switch (turn.type) {
        case TurnTypeCreatureEmpty: {
            [self performEmpty:turn completion:completion];
        } break;
        case TurnTypeCreatureMove: {
            [self performMove:turn completion:completion];
        } break;
        case TurnTypeCreatureEat: {
            [self performEat:turn completion:completion];
        } break;
        case TurnTypeCreatureReproduce: {
            [self performReproduce:turn completion:completion];
        } break;
        case TurnTypeCreatureDie: {
            [self performDie:turn completion:completion];
        } break;
        case TurnTypeCreatureBorn: { assert(false); //creature can't born itself
        } break;
    }
}

- (void)beforeEveryTurn { assert(false); /*must be overriden*/ }
- (void)afterEveryTurn { assert(false); /*must be overriden*/ }

- (Turn *)decideTurnForCurrentCell:(WorldCell *)currentCell
                      posibleCells:( NSSet<WorldCell *> *)posibleCells
{ assert(false); /*must be overriden*/ }

#pragma mark - Private

- (void)performEmpty:(Turn *)turn
          completion:(void(^)(void))completion
{
    [_animator performAnimationsForTurn:turn
                         withCompletion:^{
        completion();
    } completionQueue:_queue];
}

- (void)performDie:(Turn *)turn
        completion:(void(^)(void))completion
{
    [_animator performAnimationsForTurn:turn
                         withCompletion:^{
        [self->_world removeFromVisualCreature:turn.creature];
        [self->_world removeCreature:turn.creature atCell:turn.cell];
        [self->_world unlockCell:turn.cell];
        
        completion();
    } completionQueue:_queue];
}

- (void)performMove:(Turn *)turn
         completion:(void(^)(void))completion
{
    [_world moveCreature:self
                fromCell:turn.cell
                  toCell:turn.targetCell];
    
    [_world unlockCell:turn.cell];
    
    [_animator performAnimationsForTurn:turn
                         withCompletion:^{
        [self->_world unlockCell:turn.targetCell];
        
        completion();
    } completionQueue:_queue];
}

- (void)performReproduce:(Turn *)turn
              completion:(void(^)(void))completion
{
    id<CreatureProtocol> newCreature = [self->_world creatureForClass:self.class];
    [self->_world addCreature:newCreature atCell:turn.targetCell];
    newCreature.busy = YES;

    [_animator performAnimationsForTurn:turn
                         withCompletion:^{
        [self->_world unlockCell:turn.cell];
                
        Turn *nextTurn = [Turn bornTurnWithCreature:newCreature
                                        currentCell:turn.targetCell];
        completion();
        
        [self->_world addToVisualCreature:newCreature atCell:turn.targetCell];
        
        [newCreature.animator performAnimationsForTurn:nextTurn
                                        withCompletion:^(){
            [self->_world unlockCell:turn.targetCell];
            newCreature.busy = NO;
            
            if (self->_world.isPlaying) {
                [newCreature start];
            }
        } completionQueue:self->_queue];
    }  completionQueue:dispatch_get_main_queue()];
}

- (void)performEat:(Turn *)turn
        completion:(void(^)(void))completion
{
    id<CreatureProtocol> targetCreature = [turn.otherCreatures anyObject];
    
    [targetCreature stop];
    
    [_world moveCreature:self
                fromCell:turn.cell
                  toCell:turn.targetCell];
    
    [_world unlockCell:turn.cell];
    
    [_animator performAnimationsForTurn:turn
                         withCompletion:^{
        [self->_world unlockCell:turn.targetCell];
        
        Turn *nextTurn = [Turn dieTurnWithCreature:targetCreature
                                       currentCell:turn.targetCell];
        completion();
        [targetCreature.animator performAnimationsForTurn:nextTurn
                                           withCompletion:^{
            [self->_world removeFromVisualCreature:targetCreature];
            [self->_world removeCreature:targetCreature atCell:nil];
        } completionQueue:self->_queue];
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
