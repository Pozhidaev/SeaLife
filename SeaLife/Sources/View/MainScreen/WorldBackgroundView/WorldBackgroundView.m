//
//  WorldBackgroundView.m
//  SeaLife
//
//  Created by Sergey Pozhidaev on 11.05.2023.
//  Copyright © 2023 Sergey Pozhidaev. All rights reserved.
//

#import "WorldBackgroundView.h"

@interface WorldBackgroundView()
@end

@implementation WorldBackgroundView

- (void)drawRect:(CGRect)rect {
    CGFloat cellLineWidth = kWorldBackgroundViewCellLineWidth;
    CGFloat frameLineWidth = kWorldBackgroundViewBorderLineWidth;
    CGColorRef cellLineColor = [UIColor colorNamed:@"WorldCellsColor"].CGColor;
    CGColorRef cellFillColor = [UIColor colorNamed:@"WorldBackgroundColor"].CGColor;
    CGColorRef frameLineColor = [UIColor colorNamed:@"WorldFrameColor"].CGColor;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);

    CGContextSetFillColorWithColor(context, cellFillColor);
    CGContextFillRect(context, rect);

    if (([UIDevice.currentDevice userInterfaceIdiom] == UIUserInterfaceIdiomPhone && self.sizeInCells.height <= kWorldBackgroundViewMaxVerticalSizeForDrawingGridIphone) ||
        ([UIDevice.currentDevice userInterfaceIdiom] == UIUserInterfaceIdiomPad && self.sizeInCells.height <= kWorldBackgroundViewMaxVerticalSizeForDrawingGridIpad)) {
        CGContextSetStrokeColorWithColor(context, cellLineColor);
        CGContextSetLineWidth(context, cellLineWidth);

        float cellWidth = CGRectGetWidth(self.bounds) / self.sizeInCells.width;
        float cellHeight = CGRectGetHeight(self.bounds) / self.sizeInCells.height;
        
        for (int y_stepper = 0; y_stepper <= self.sizeInCells.height; y_stepper++) {
            CGFloat y = MIN(y_stepper * cellHeight, CGRectGetHeight(self.bounds) - cellLineWidth);
            CGContextMoveToPoint(context, 0.0, y);
            CGContextAddLineToPoint(context, CGRectGetWidth(self.bounds), y);
            CGContextStrokePath(context);
        }
       
        for (int x_stepper = 0; x_stepper <= self.sizeInCells.width; x_stepper++) {
            CGFloat x = MIN(x_stepper * cellWidth, CGRectGetWidth(self.bounds) - cellLineWidth);
            CGContextMoveToPoint(context, x, 0.0);
            CGContextAddLineToPoint(context, x, CGRectGetHeight(self.bounds));
            CGContextStrokePath(context);
        }
    }
    
    CGContextSetStrokeColorWithColor(context, frameLineColor);
    CGContextSetLineWidth(context, frameLineWidth);
    CGContextStrokeRect(context, rect);
}

@end
