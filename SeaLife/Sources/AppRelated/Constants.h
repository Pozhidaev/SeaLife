//
//  Constants.h
//  SeaLife
//
//  Created by Sergey Pozhidaev on 10.06.2014.
//  Copyright (c) 2014 Sergey Pozhidaev. All rights reserved.
//

#ifndef SeaLife_Constants_h
#define SeaLife_Constants_h

//Keys
#define kAnimationFinalTransform              @"kAnimationFinalTransform"
#define kAnimationCompletionKey               @"kAnimationCompletionKey"
#define kAnimationPreparationKey              @"kAnimationPreparationKey"

#define kAnimationKey                         @"kAnimationKey"
#define kAnimationUUIDKey                     @"kAnimationUUIDKey"
#define kTransformKey                         @"transform"

//UI
#define kDefaultCornerRadius                  8.0
#define kDefaultUIElementSpace                8.0

#define kMenuViewBorderWidth                  1.0
#define kMenuViewCornerRadius                 16.0

#define kMainScreenControlPanelViewBorderWidth  1.0

#define kWorldBackgroundViewBorderLineWidth   2.0
#define kWorldBackgroundViewCellLineWidth     1.0
#define kWorldBackgroundViewMaxVerticalSizeForDrawingGridIphone   15
#define kWorldBackgroundViewMaxVerticalSizeForDrawingGridIpad     50

#define kCreatureImageViewMinSizeForReducing  40.0
#define kCreatureImageViewReducingCoeficient  0.1

//World
#define kWorldSizeAspectRatio               1.5

#define kHorizontalWorldSizeMin            1
#define kHorizontalWorldSizeMax            50
#define kHorizontalWorldSizeDefault        10

#define kVerticalWorldSizeMin              1
#define kVerticalWorldSizeMax              50
#define kVerticalWorldSizeDefault          15

#define kDefaultfishCount                  50
#define kDefaultOrcaCount                  10

//Speed
#define kSlowestCreatureSpeed              4.0f
#define kFastestCreatureSpeed              0.1f
#define kDefaultCreatureSpeed              0.5f

#define kSlowestAnimationSpeed             2.0f
#define kFastestAnimationSpeed             0.1f
#define kDefaultAnimationSpeed             0.5f

//Creature

#define kOrcaReproductionPeriod            5
#define kFishReproductionPeriod            7

#define kOrcaAllowedHungerPoins            3

#endif
