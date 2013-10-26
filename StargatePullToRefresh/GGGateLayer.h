//
//  GGGateLayer.h
//  StargatePullToRefresh
//
//  Created by Chris Ross on 26/10/2013.
//  Copyright (c) 2013 hiddenMemory Limited. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface GGGateLayer : CALayer
@property (nonatomic) float gateProgress;
@property(nonatomic) int gateAddressPoints;
@property(nonatomic, strong) NSMutableArray *address;
@property(nonatomic) BOOL drawComplete;
@end

