//
//  UITableView+State.h
//  GroupZonePoster
//
//  Created by 刘铎 on 26/09/2017.
//  Copyright © 2017 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UITableViewState) {
    UITableViewStateNone = -1,
    UITableViewStateLoading = 0,
    UITableViewStateContent,
    UITableViewStateEmpty,
    UITableViewStateError,
    UITableViewStateContentAndLoadingList,
    UITableViewStateContentAndListEmpty,
    UITableViewStateContentAndListError,
    UITableViewStateContentAndLoadingMore,
    UITableViewStateContentAndLoadMoreError,
    UITableViewStateContentAndLoadMoreEnd
};

@interface UITableView (State)

- (void)closeSelfSizing;

- (UITableViewState)currentState;
- (void)switchState:(UITableViewState)state;

- (void)registerLoadingCellClass:(Class)cellClass;

#pragma mark - Content

- (void)setContentView:(UIView *)view;
- (UIView *)contentView;

- (void)setContentLoadingView:(UIView *)view;
- (UIView *)contentLoadingView;

- (void)setContentEmptyView:(UIView *)view;
- (UIView *)contentEmptyView;

- (void)setContentErrorView:(UIView *)view;
- (UIView *)contentErrorView;

- (void)setCalculateContentCellHeightBlock:(CGFloat (^)(UITableViewCell *))calculateHeightBlock;

#pragma mark - List

- (void)registerListCell:(Class)cellClass;

- (void)setListEmptyView:(UIView *)view;
- (UIView *)listEmptyView;

- (void)setListErrorView:(UIView *)view;
- (UIView *)listErrorView;

- (void)registerLoadMoreEmptyCellClass:(Class)cellClass;
- (void)registerLoadMoreErrorCellClass:(Class)cellClass;

- (void)setCalculateListCellHeightBlock:(CGFloat (^)(NSIndexPath *))calculateHeightBlock;

#pragma mark -

- (NSUInteger)handleNumberOfSections;
- (NSUInteger)handleNumberOfRowsInSection:(NSUInteger)section;
- (UITableViewCell *)handleCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)handleHeightForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
