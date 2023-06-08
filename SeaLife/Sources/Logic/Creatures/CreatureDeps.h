//
//  CreatureDeps.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 06.06.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WorldProtocol;
@protocol TurnHelperProtocol;
@class CreatureAnimator;

NS_ASSUME_NONNULL_BEGIN

@interface CreatureDeps : NSObject

@property (nonatomic, weak) Class<TurnHelperProtocol> turnHelperClass;
@property (nonatomic, weak) id<WorldProtocol> world;

@end

NS_ASSUME_NONNULL_END
