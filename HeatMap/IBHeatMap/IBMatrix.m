//
//  IBMatrix.m
//  Ivan Bruel
//
//  Created by Ivan Bruel on 02/07/14.
//  Copyright (c) 2014 Ivan Bruel. All rights reserved.
//

#import "IBMatrix.h"

@interface IBMatrix ()

@property (nonatomic, strong) NSMutableArray *matrix;

@end

@implementation IBMatrix

- (instancetype)initWithColumns:(NSInteger)columns lines:(NSInteger)lines
{
  return [self initWithColumns:columns lines:lines fillWith:[NSNull null]];
}

- (instancetype)initWithColumns:(NSInteger)columns lines:(NSInteger)lines fillWith:(id)obj
{
  self = [super init];
  if (self) {
    NSMutableArray *matrix = [[NSMutableArray alloc]initWithCapacity:lines * columns];
    for (NSInteger index = 0; index < lines * columns; index ++) {
      if(obj != nil)
        [matrix addObject:obj];
      else
        [matrix addObject:[NSNull null]];
    }
    self.matrix = matrix;
    _columns = columns;
    _lines = lines;
  }
  return self;
}

- (void)setObject:(id)object column:(NSInteger)column line:(NSInteger)line
{
  NSInteger index = self.columns * line + column;
  if(object == nil)
    self.matrix[index] = [NSNull null];
  else
    self.matrix[index] = object;
}

- (id)objectForColumn:(NSInteger)column line:(NSInteger)line
{
  NSInteger index = self.columns * line + column;
  id obj = self.matrix[index];
  if([obj isEqual:[NSNull null]])
    return nil;
  else
    return obj;
}


@end
