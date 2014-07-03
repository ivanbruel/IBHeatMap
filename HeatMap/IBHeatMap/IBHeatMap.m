//
//  IBHeatMap.m
//  Ivan Bruel
//
//  Created by Ivan Bruel on 02/07/14.
//  Copyright (c) 2014 Ivan Bruel. All rights reserved.
//

#import "IBHeatMap.h"
#import "IBMatrix.h"

@interface IBHeatMap ()

@property (nonatomic, strong) IBMatrix *colorMatrix;
@property (nonatomic, strong) IBMatrix *densityMatrix;
@end


@implementation IBHeatMap
#pragma mark - Initialization
- (id)initWithFrame:(CGRect)frame points:(NSArray *)points colors:(NSArray *)colors pointRadius:(CGFloat)pointRadius
{
    self = [super initWithFrame:frame];
    if(self) {
        _colors = colors;
        _points = points;
        _pointRadius = pointRadius;
        self.backgroundColor = [UIColor clearColor];
        [self redrawView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _colors = @[];
    _points = @[];
    _pointRadius = 0;
    self.backgroundColor = [UIColor clearColor];
    [self redrawView];
}

- (void)setColors:(NSArray *)colors
{
    _colors = colors;
    [self redrawView];
}

- (void)setPoints:(NSArray *)points
{
    _points = points;
    [self redrawView];
}

- (void)setPointRadius:(CGFloat)pointRadius
{
    _pointRadius = pointRadius;
    [self redrawView];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (NSInteger x = 0; x < CGRectGetWidth(self.bounds); x ++) {
        for (NSInteger y = 0; y < CGRectGetHeight(self.bounds); y ++) {
            UIColor *color = [self.colorMatrix objectForColumn:x line:y];
            if ([color isKindOfClass:[UIColor class]]) {
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextFillRect(context, CGRectMake(x, y, 1, 1));
            }
        }
    }
}


#pragma mark - Logic
- (void)redrawView
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self calculatePixelColors];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.delegate != nil && [self.delegate respondsToSelector:@selector(heatMapFinishedLoading)]) {
                [self.delegate heatMapFinishedLoading];
            }
            [self setNeedsDisplay];
        });
    });
}

#pragma mark - Pixel Calculator
- (void)calculatePixelColors
{
    CGFloat maxDensity = [self maxDensityCalc];
    IBMatrix *matrix = [[IBMatrix alloc]initWithColumns:CGRectGetWidth(self.bounds) lines:CGRectGetHeight(self.bounds)];
    for (NSInteger x = 0; x < CGRectGetWidth(self.bounds); x ++) {
        for (NSInteger y = 0; y < CGRectGetHeight(self.bounds); y ++) {
            CGFloat density = [[self.densityMatrix objectForColumn:x line:y]doubleValue];
            UIColor *color = [self colorForDensity:density andMaxDensity:maxDensity];
            [matrix setObject:color column:x line:y];
        }
    }
    self.colorMatrix = matrix;
}

#pragma mark - Helpers
- (UIColor *)colorForDensity:(CGFloat)density andMaxDensity:(CGFloat)maxDensity
{
    if(density < 1)
        return [self colorLerpFrom:[UIColor clearColor] to:self.colors[0] withDuration:density];
    
    CGFloat densityPercentage = density / maxDensity;
    CGFloat colorArrayPercentage = (self.colors.count - 1) * densityPercentage;
    
    NSInteger firstColorIndex = floor(colorArrayPercentage);
    NSInteger secondColorIndex = ceil(colorArrayPercentage);
    
    CGFloat colorRatio = colorArrayPercentage - firstColorIndex;
    
    return [self colorLerpFrom:self.colors[firstColorIndex] to:self.colors[secondColorIndex] withDuration:colorRatio];
}

- (CGFloat)densityForPoint:(CGPoint)point
{
    CGFloat density = 0;
    for (NSValue *value in self.points) {
        CGPoint userPoint = value.CGPointValue;
        CGPoint absoluteUserPoint = [self absolutePointForRelativePoint:userPoint];
        CGFloat distanceBetweenPointAndCircle = abs(hypotf(point.x - absoluteUserPoint.x, point.y - absoluteUserPoint.y));
        if(distanceBetweenPointAndCircle <= self.pointRadius) {
            density+=(self.pointRadius - distanceBetweenPointAndCircle) / self.pointRadius;
        }
    }
    return density;
    
}

- (CGFloat)maxDensityCalc
{
    IBMatrix *densityMatrix = [[IBMatrix alloc]initWithColumns:CGRectGetWidth(self.bounds) lines:CGRectGetHeight(self.bounds)];
    CGFloat maxDensity = 0;
    __block CGFloat firstMaxDensity = 0;
    __block CGFloat secondMaxDensity = 0;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        for(NSInteger x = 0; x < floor(CGRectGetWidth(self.bounds) / 2.0f); x++) {
            for(NSInteger y = 0; y < CGRectGetHeight(self.bounds); y++) {
                CGPoint point = CGPointMake(x, y);
                CGFloat density = [self densityForPoint:point];
                [densityMatrix setObject:@(density) column:x line:y];
                if (density > firstMaxDensity)
                    firstMaxDensity = density;
            }
        }
        dispatch_semaphore_signal(sem);
    });
    dispatch_async(queue, ^{
        for(NSInteger x = floor(CGRectGetWidth(self.bounds) / 2.0f); x < CGRectGetWidth(self.bounds); x++) {
            for(NSInteger y = 0; y < CGRectGetHeight(self.bounds); y++) {
                CGPoint point = CGPointMake(x, y);
                CGFloat density = [self densityForPoint:point];
                [densityMatrix setObject:@(density) column:x line:y];
                if (density > secondMaxDensity)
                    secondMaxDensity = density;
            }
        }
        dispatch_semaphore_signal(sem);
    });
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    maxDensity = firstMaxDensity>secondMaxDensity?firstMaxDensity:secondMaxDensity;
    self.densityMatrix = densityMatrix;
    return maxDensity;
}

- (CGPoint)absolutePointForRelativePoint:(CGPoint)point
{
    return CGPointMake(point.x * CGRectGetWidth(self.bounds), point.y * CGRectGetHeight(self.bounds));
}

- (UIColor *)colorLerpFrom:(UIColor *)start
                        to:(UIColor *)end
              withDuration:(float)t
{
    if(t < 0.0f) t = 0.0f;
    if(t > 1.0f) t = 1.0f;
    
    const CGFloat *startComponent = CGColorGetComponents(start.CGColor);
    const CGFloat *endComponent = CGColorGetComponents(end.CGColor);
    
    float startAlpha = CGColorGetAlpha(start.CGColor);
    float endAlpha = CGColorGetAlpha(end.CGColor);
    
    float r = startComponent[0] + (endComponent[0] - startComponent[0]) * t;
    float g = startComponent[1] + (endComponent[1] - startComponent[1]) * t;
    float b = startComponent[2] + (endComponent[2] - startComponent[2]) * t;
    float a = startAlpha + (endAlpha - startAlpha) * t;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
