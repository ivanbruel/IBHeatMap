//
//  IBViewController.m
//  HeatMap
//
//  Created by Ivan Bruel on 03/07/14.
//  Copyright (c) 2014 Ivan Bruel. All rights reserved.
//

#import "IBViewController.h"
#import "IBHeatMap.h"

@interface IBViewController () <IBHeatMapDelegate>

@property (nonatomic, strong) IBHeatMap *heatMap;

@end

@implementation IBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray *locations = [@[] mutableCopy];
    for(NSInteger index = 0; index < 10; index ++) {
        CGPoint point = CGPointMake(((float)rand() / RAND_MAX) * 1,((float)rand() / RAND_MAX) * 1);
        [locations addObject:[NSValue valueWithCGPoint:point]];
    }

    self.heatMap = [[IBHeatMap alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)) points:locations colors:@[[UIColor greenColor], [UIColor yellowColor], [UIColor redColor]] pointRadius:40.0f];
    self.heatMap.delegate = self;
    self.heatMap.alpha = 0.8f;
    [self.view addSubview:self.heatMap];
	// Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addPointToHeatMap:)];
    [self.heatMap addGestureRecognizer:tapGesture];
}

- (IBAction)addPointToHeatMap:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    CGPoint relativePoint = CGPointMake(point.x / sender.view.frame.size.width, point.y / sender.view.frame.size.height);
    NSMutableArray *points = [self.heatMap.points mutableCopy];
    [points addObject:[NSValue valueWithCGPoint:relativePoint]];
    self.heatMap.points = points;
}

-(void)heatMapFinishedLoading {
    NSLog(@"FinishedLoadingHeatMap");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
