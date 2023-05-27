//
//  TurnType.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#ifndef TurnType_h
#define TurnType_h

typedef NS_ENUM(NSInteger, TurnType) {
    TurnTypeCreatureEmpty,
    TurnTypeCreatureMove,
    TurnTypeCreatureEat,
    TurnTypeCreatureReproduce,
    TurnTypeCreatureBorn,
    TurnTypeCreatureDie,
};

#endif /* TurnType_h */
