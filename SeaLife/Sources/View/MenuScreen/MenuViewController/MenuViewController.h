//
//  MenuViewController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WorldProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface MenuViewController : UIViewController

@property (nonatomic) struct WorldInfo worldInfo;
@property (nonatomic) void(^onDismiss)(void);

@end

NS_ASSUME_NONNULL_END
