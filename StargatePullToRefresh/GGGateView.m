//
// Created by Chris Ross on 26/10/2013.
// Copyright (c) 2013 hiddenMemory Limited. All rights reserved.
//


#import "GGGateView.h"
#import "GGGateLayer.h"

@implementation GGGateView {

}
+ (Class)layerClass {
    return [GGGateLayer class];
}
- (GGGateLayer*)gateLayer {
    return (GGGateLayer *) self.layer;
}
@end