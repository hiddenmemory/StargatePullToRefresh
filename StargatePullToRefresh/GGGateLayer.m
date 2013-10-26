//
//  GGGateLayer.m
//  StargatePullToRefresh
//
//  Created by Chris Ross on 26/10/2013.
//  Copyright (c) 2013 hiddenMemory Limited. All rights reserved.
//

#import "GGGateLayer.h"

#define RANDOM_RANGE( FROM, TO ) (((TO - FROM) * ((random() % RAND_MAX) / (0.0 + RAND_MAX))) + FROM)

@implementation GGGateLayer {
    double offsetAngle;
}

@dynamic gateProgress;
+ (BOOL)needsDisplayForKey:(NSString*)key {
    return [key isEqualToString:@"gateProgress"] || [super needsDisplayForKey:key];
}

- (id)init {
    self = [super init];
    if( self ) {
        self.gateAddressPoints = 32;
        
        self.address = [NSMutableArray array];
        for( int i = 0; i < 10; i++ ) {
            int value = 0;
            do {
                value = (int) RANDOM_RANGE(0, self.gateAddressPoints);
            } while( [self.address containsObject:@(value)] );
            [self.address addObject:@(value)];
        }
        
        NSLog(@"Address list: %@", self.address);
    }
    return self;
}

- (id)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    if( self ) {
        GGGateLayer *source = layer;
        self.gateAddressPoints = source.gateAddressPoints;
        self.address = source.address;
    }
    return self;
}

- (void)drawSegments:(CGContextRef)context {
    CGFloat radius = (self.bounds.size.width / 2) - 6;
    CGFloat bandThickness = 3;
    
    CGColorRef lightGray = [UIColor lightGrayColor].CGColor;
    CGColorRef darkGray = [UIColor darkGrayColor].CGColor;
    
    CGFloat total = 0.f;
    CGFloat value = 100.f / self.gateAddressPoints;
    
    for( int i = 0; i < self.gateAddressPoints; i++ ) {
        CGFloat startAngle = offsetAngle + (total / 100.f) * (M_PI * 2) - M_PI_2;
        CGFloat endAngle = offsetAngle + ((total + value) / 100.f) * (M_PI * 2) - M_PI_2;
        
        CGContextSetFillColorWithColor(context, (i % 2 == 0 ? lightGray : darkGray));
        [self renderArc:context radius:radius bandThickness:bandThickness startAngle:startAngle endAngle:endAngle];
        
        total += value;
    };
}
- (void)drawOuterRing:(CGContextRef)context {
    CGColorRef darkGray = [UIColor darkGrayColor].CGColor;
    CGContextSetFillColorWithColor(context, darkGray);
    [self renderArc:context
             radius:(self.bounds.size.width / 2) - 1
      bandThickness:5.f
         startAngle:0.f
           endAngle:M_PI * 2];
    
}
- (void)renderArc:(CGContextRef)context radius:(CGFloat)radius bandThickness:(CGFloat)bandThickness startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat centerY = self.bounds.size.height / 2;
    
    CGContextSaveGState(context);
    {
        CGMutablePathRef path = CGPathCreateMutable();
        
        CGPathAddArc(path, NULL, centerX, centerY, radius, startAngle, endAngle, NO);
        CGPathAddLineToPoint(path, NULL, centerX + (radius - bandThickness) * cos(endAngle), centerY + (radius - bandThickness) * sin(endAngle));
        CGPathAddArc(path, NULL, centerX, centerY, radius - bandThickness, endAngle, startAngle, YES);
        CGPathAddLineToPoint(path, NULL, centerX + (radius * cos(startAngle)), centerY + (radius * sin(startAngle)));
        CGPathCloseSubpath(path);
        
        CGContextAddPath(context, path);
        CGContextFillPath(context);
        CFRelease(path);
    }
    CGContextRestoreGState(context);
}

- (void)drawBulbs:(CGContextRef)context offset:(int)offset {
    CGColorRef highlight = [UIColor yellowColor].CGColor;
    CGColorRef lowlight = [UIColor orangeColor].CGColor;
    
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat centerY = self.bounds.size.height / 2;
    CGFloat radius = (self.bounds.size.width / 2) - 4;
    CGFloat bandThickness = 3.f;
    
    for( int i = 0; i < 9; i++ ) {
        CGFloat angle = (M_PI * 2) * ((9 - i) / 9.f) + (M_PI * 2 * 0.1);
        
        if( offset > i ) {
            CGContextSetFillColorWithColor(context, highlight);
        }
        else {
            CGContextSetFillColorWithColor(context, lowlight);
        }
        
        CGContextFillEllipseInRect(context, CGRectMake(
                                                       centerX + (radius * cos(angle)) - (bandThickness / 2),
                                                       centerY + (radius * sin(angle)) - (bandThickness / 2),
                                                       bandThickness,
                                                       bandThickness));
    }
}

- (void)drawInContext:(CGContextRef)context {
    [super drawInContext:context];

    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    int offset = 10;
    if( !self.drawComplete ) {
        offset = ((int)self.gateProgress) / 10;
        CGFloat partialOffset = (self.gateProgress - (offset * 10)) / 10;
        
        CGFloat segmentCount = 0.f + self.gateAddressPoints;
        int start = [[self.address objectAtIndex:MIN((NSUInteger) offset, [self.address count] - 1)] intValue];
        int end = [[self.address objectAtIndex:MIN((NSUInteger) offset + 1, [self.address count] - 1)] intValue];
        
        CGFloat startAngle = (M_PI * 2) * (start / segmentCount);
        CGFloat endAngle = (M_PI * 2) * (end / segmentCount);
        
        offsetAngle = startAngle + ((endAngle - startAngle) * partialOffset);
    }
    
    if( self.drawComplete || offset >= 9 ) {
        CGContextSetFillColorWithColor(
                                       context,
                                       [UIColor colorWithRed:0.427 green:0.588 blue:0.741 alpha:0.8f].CGColor
                                       );
        CGContextFillEllipseInRect(context, CGRectMake(5, 5, self.bounds.size.width - 10, self.bounds.size.height - 10));
    }
    
    [self drawSegments:context];
    [self drawOuterRing:context];
    [self drawBulbs:context offset:offset];
}

@end