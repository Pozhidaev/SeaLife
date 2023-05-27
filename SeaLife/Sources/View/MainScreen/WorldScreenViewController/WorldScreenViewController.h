//
//  WorldScreenViewController.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WorldViewControllerDelegate.h"

@protocol WorldViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface WorldScreenViewController : UIViewController <UIAlertViewDelegate, WorldViewControllerDelegate>

@end

NS_ASSUME_NONNULL_END
