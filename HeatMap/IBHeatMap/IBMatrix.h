//
//  IBMatrix.h
//  Ivan Bruel
//
//  Created by Ivan Bruel on 02/07/14.
//  Copyright (c) 2014 Ivan Bruel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IBMatrix : NSObject

- (instancetype)initWithColumns:(NSInteger)columns lines:(NSInteger)lines;
- (instancetype)initWithColumns:(NSInteger)columns lines:(NSInteger)lines fillWith:(id)obj;

- (void)setObject:(id)object column:(NSInteger)column line:(NSInteger)line;
- (id)objectForColumn:(NSInteger)column line:(NSInteger)line;

@property (nonatomic, readonly) NSInteger lines;
@property (nonatomic, readonly) NSInteger columns;


@end
