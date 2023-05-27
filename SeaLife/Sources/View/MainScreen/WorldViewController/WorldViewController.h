//
//  WorldViewController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WorldDelegate.h"

@protocol WorldViewControllerDelegate;
@protocol WorldProtocol;
@class Turn;
struct WorldInfo;

NS_ASSUME_NONNULL_BEGIN

@interface WorldViewController : UIViewController<WorldDelegate>

@property (nonatomic) float creaturesSpeed;
@property (nonatomic) float animationSpeed;

@property (nonatomic, weak) id<WorldViewControllerDelegate> delegate;

- (void)play;
- (void)stop;
- (void)reset;

- (void)createWorldWithInfo:(struct WorldInfo)worldInfo;

@end

NS_ASSUME_NONNULL_END
