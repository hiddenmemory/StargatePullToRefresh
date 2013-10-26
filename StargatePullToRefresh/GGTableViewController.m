//
//  GGTableViewController.m
//  StargatePullToRefresh
//
//  Created by Chris Ross on 26/10/2013.
//  Copyright (c) 2013 hiddenMemory Limited. All rights reserved.
//

#import "GGTableViewController.h"
#import "GGGateView.h"
#import "GGGateLayer.h"

@interface GGTableViewController ()

@end

#define REFRESH_HEADER_HEIGHT 50.0f

@implementation GGTableViewController {
    UIView *headerView;
    GGGateView *gateView;
    BOOL isLoading;
    BOOL isDragging;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addPullToRefreshHeader];
}

- (void)addPullToRefreshHeader {
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT, 320, REFRESH_HEADER_HEIGHT)];
    headerView.backgroundColor = [UIColor clearColor];

    gateView = [[GGGateView alloc] initWithFrame:CGRectMake(135, 0, 50, 50)];
    gateView.backgroundColor = [UIColor clearColor];
    gateView.gateLayer.contentsScale = [[UIScreen mainScreen] scale];

    [headerView addSubview:gateView];
    [self.tableView addSubview:headerView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.tableView.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.tableView.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT + 20, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        CGFloat progress = MIN(100, MAX(0, (0 - scrollView.contentOffset.y - 30)));
        [gateView.gateLayer setValue:@(progress) forKey:@"gateProgress"];
        [gateView.gateLayer setNeedsDisplay];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;

    if (scrollView.contentOffset.y <= -100.f) {
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;

    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;

    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self performSelector:@selector(stopLoading) withObject:nil afterDelay:2.0];
}

@end
