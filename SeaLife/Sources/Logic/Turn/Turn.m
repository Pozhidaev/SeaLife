//
//  Turn.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright (c) 2023 Sergey Pozhidaev. All rights reserved.
//

#import "Turn.h"

#import "WorldCell.h"
#import "CreatureProtocol.h"
#import "Direction.h"
#import "TurnType.h"
#import "WorldPosition.h"

@interface Turn()

@property (nonatomic, readwrite) TurnType type;
@property (nonatomic, readwrite) id<CreatureProtocol> creature;
@property (nonatomic, readwrite, weak) WorldCell *cell;
@property (nonatomic, readwrite, nullable) NSHashTable<WorldCell *> *otherCells;
@property (nonatomic, readwrite, nullable) NSHashTable<id<CreatureProtocol>> *otherCreatures;

@end

@implementation Turn

#pragma mark - Factory

+ (instancetype)emptyTurnWithCreature:(id<CreatureProtocol>)creture
                          currentCell:(WorldCell *)currentCell
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureEmpty
                                       cell:currentCell
                                   creature:creture
                                 otherCells:nil
                             otherCreatures:nil];
    return turn;
}

+ (nonnull instancetype)bornTurnWithCreature:(id<CreatureProtocol>)creture
                                 currentCell:(WorldCell *)currentCell
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureBorn
                                       cell:currentCell
                                   creature:creture
                                 otherCells:nil
                             otherCreatures:nil];
    return turn;
}

+ (instancetype)dieTurnWithCreature:(id<CreatureProtocol>)creture
                        currentCell:(WorldCell *)currentCell
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureDie
                                       cell:currentCell
                                   creature:creture
                                 otherCells:nil
                             otherCreatures:nil];
    return turn;
}

+ (instancetype)moveTurnWithCreature:(id<CreatureProtocol>)creture
                         currentCell:(WorldCell *)currentCell
                          targetCell:(WorldCell *)targetCell
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureMove
                                       cell:currentCell
                                   creature:creture
                                 otherCells:[NSSet setWithObject:targetCell]
                             otherCreatures:nil];
    return turn;
}

+ (instancetype)eatTurnWithCreature:(id<CreatureProtocol>)creture
                        currentCell:(WorldCell *)currentCell
                         targetCell:(WorldCell *)targetCell
                      otherCreature:(id<CreatureProtocol>)otherCreture
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureEat
                                       cell:currentCell
                                   creature:creture
                                 otherCells:[NSSet setWithObject:targetCell]
                             otherCreatures:[NSSet setWithObject:otherCreture]];
    return turn;
}

+ (instancetype)reproduceTurnWithCreature:(id<CreatureProtocol>)creture
                              currentCell:(WorldCell *)currentCell
                               targetCell:(WorldCell *)targetCell
{
    Turn *turn = [[Turn alloc] initWithType:TurnTypeCreatureReproduce
                                       cell:currentCell
                                   creature:creture
                                 otherCells:[NSSet setWithObject:targetCell]
                             otherCreatures:nil];
    return turn;
}

#pragma mark - Initializer

- (instancetype)initWithType:(TurnType)type
                        cell:(WorldCell *)cell
                    creature:(id<CreatureProtocol>)creature
                  otherCells:(NSSet<WorldCell *> *)otherCells
              otherCreatures:(NSSet<id<CreatureProtocol>> *)otherCreatures
{
    self = [super init];
    if (self) {
        self.type = type;
        self.cell = cell;
        self.creature = creature;

        self.otherCreatures = [[NSHashTable alloc] init];
        for (id<CreatureProtocol> creature in otherCreatures) {
            [self.otherCreatures addObject:creature];
        }

        self.otherCells = [[NSHashTable alloc] init];
        for (WorldCell *cell in otherCells) {
            [self.otherCells addObject:cell];
        }
    }
    return self;
}

#pragma mark - Public

- (Direction)direction
{
    if ([self.otherCells count] == 1) {
        if ([self.otherCells anyObject].position.x < self.cell.position.x) {
            return DirectionLeft;
        } else if ([self.otherCells anyObject].position.x > self.cell.position.x) {
            return DirectionRight;
        } else if ([self.otherCells anyObject].position.y < self.cell.position.y) {
            return DirectionUp;
        } else if ([self.otherCells anyObject].position.y > self.cell.position.y) {
            return DirectionDown;
        }
    } else if ([self.otherCells count] > 1) {
        return DirectionMulty;
    }
    
    return DirectionNone;
}

- (struct WorldPosition)finalPosition
{
    switch (self.type) {
        case TurnTypeCreatureEmpty:
            return self.creature.position;
        case TurnTypeCreatureMove:
            return [self.otherCells anyObject].position;
        case TurnTypeCreatureEat:
            return [self.otherCells anyObject].position;
        case TurnTypeCreatureReproduce:
            return self.cell.position;
        case TurnTypeCreatureBorn:
            return self.cell.position;
        case TurnTypeCreatureDie:
            return self.cell.position;
    }
}

- (WorldCell *)targetCell
{
    return [self.otherCells anyObject];
}

- (NSSet<WorldCell*> *)usedCells
{
    switch (self.type) {
        case TurnTypeCreatureEmpty:
            return [NSSet set];
        case TurnTypeCreatureMove:
            return [[NSSet setWithObject:self.cell] setByAddingObjectsFromArray:[self.otherCells allObjects]];
        case TurnTypeCreatureEat:
            return [[NSSet setWithObject:self.cell] setByAddingObjectsFromArray:[self.otherCells allObjects]];
        case TurnTypeCreatureReproduce:
            return [[NSSet setWithObject:self.cell] setByAddingObjectsFromArray:[self.otherCells allObjects]];
        case TurnTypeCreatureBorn:
            return [NSSet setWithObject:self.cell];
        case TurnTypeCreatureDie:
            return [NSSet set];
    }
}

- (NSString *)debugDescription
{
    NSMutableString *description = [[NSMutableString alloc] initWithString:@"======= turn =======\n"];
    
    switch (self.type) {
        case TurnTypeCreatureEmpty: { [description appendFormat:@"Type :: Empty\n"]; } break;
        case TurnTypeCreatureBorn: { [description appendFormat:@"Type :: Born\n"]; } break;
        case TurnTypeCreatureDie: { [description appendFormat:@"Type :: Die\n"]; } break;
        case TurnTypeCreatureMove: { [description appendFormat:@"Type :: Move\n"]; } break;
        case TurnTypeCreatureEat: { [description appendFormat:@"Type :: Eat\n"]; } break;
        case TurnTypeCreatureReproduce: { [description appendFormat:@"Type :: Reproduce\n"]; } break;
    }

    switch (self.direction) {
        case DirectionUp: { [description appendFormat:@"Direction :: Up\n"]; } break;
        case DirectionDown: { [description appendFormat:@"Direction :: Down\n"]; } break;
        case DirectionLeft: { [description appendFormat:@"Direction :: Left\n"]; } break;
        case DirectionRight: { [description appendFormat:@"Direction :: Right\n"]; } break;
        case DirectionNone: { [description appendFormat:@"Direction :: None\n"]; } break;
        case DirectionMulty: { [description appendFormat:@"Direction :: Multy\n"]; } break;
    }

    [description appendFormat:@"Cell :: %@", [self.cell debugDescription]];
    for (WorldCell *otherCell in self.otherCells) {
        [description appendFormat:@"Other cell :: %@", [otherCell debugDescription]];
    }

    [description appendFormat:@"Creature :: %@\n", [self.creature debugDescriptionIndent:3 caption:@""]];
    for (id<CreatureProtocol> otherCreature in self.otherCreatures) {
        [description appendFormat:@"\nOther creature :: %@\n", [otherCreature debugDescriptionIndent:3 caption:@""]];
    }
    
    [description appendString:@"======================================================"];
    
    return [description copy];
}

@end
