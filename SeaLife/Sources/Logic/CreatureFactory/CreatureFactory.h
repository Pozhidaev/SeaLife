//
//  CreatureFactory.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;
@class CreatureDeps;

NS_ASSUME_NONNULL_BEGIN

@interface CreatureFactory : NSObject

+ (id<CreatureProtocol>)creatureWithClass:(Class)creatureClass
                                    deps:(CreatureDeps *)deps;

+ (id<CreatureProtocol>)orcaCreatureWithDeps:(CreatureDeps *)deps;
+ (id<CreatureProtocol>)fishCreatureWithDeps:(CreatureDeps *)deps;

@end

NS_ASSUME_NONNULL_END
