//
//  CreatureFactory.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface CreatureFactory : NSObject

+ (id<CreatureProtocol>)creatureFromCreature:(id<CreatureProtocol>)creature;
+ (id<CreatureProtocol>)orcaCreature;
+ (id<CreatureProtocol>)fishCreature;

@end

NS_ASSUME_NONNULL_END
