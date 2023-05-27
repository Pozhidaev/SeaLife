//
//  WorldCell.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreatureProtocol;
struct WorldPosition;

NS_ASSUME_NONNULL_BEGIN

@interface WorldCell : NSObject

@property(nonatomic, readonly) struct WorldPosition position;
@property(nonatomic, weak) id<CreatureProtocol> creature;

- (instancetype)initWithPosition:(struct WorldPosition)position;

- (NSString *)debugDescription;

@end

NS_ASSUME_NONNULL_END
