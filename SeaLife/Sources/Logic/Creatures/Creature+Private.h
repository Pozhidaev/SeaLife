//
//  Creature+Private.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 23.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

@class Turn;
@class WorldCell;

NS_ASSUME_NONNULL_BEGIN

@interface Creature()
{
    @protected Class _turnHelperClass;
}

- (Turn *)tryMoveFromCell:(WorldCell *)currentCell
            possibleCells:(NSSet<WorldCell *> *)possibleCells;
- (Turn *)tryReproduceFromCell:(WorldCell *)currentCell
                 possibleCells:(NSSet<WorldCell *> *)possibleCells;
- (Turn *)tryEatFromCell:(WorldCell *)currentCell
           possibleCells:(NSSet<WorldCell *> *)possibleCells;

@end

NS_ASSUME_NONNULL_END
