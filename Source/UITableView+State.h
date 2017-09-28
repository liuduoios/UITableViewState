//
//  UITableView+State.h
//  GroupZonePoster
//
//  Created by 刘铎 on 26/09/2017.
//  Copyright © 2017 xxx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, UITableViewState) {
    UITableViewStateLoading,
    UITableViewStateContent,
    UITableViewStateEmpty,
    UITableViewStateError,
    UITableViewStateContentAndLoadingList,
    UITableViewStateContentAndList,
    UITableViewStateContentAndListEmpty,
    UITableViewStateContentAndListError,
    UITableViewStateContentAndLoadingMore,
    UITableViewStateContentAndLoadMoreError,
    UITableViewStateContentAndLoadMoreEmpty
};

@interface UITableView (State)

- (void)closeSelfSizing;

- (UITableViewState)currentState;
- (void)switchState:(UITableViewState)state;

- (void)setContentCell:(UIView *)cell;
- (void)registerListCell:(Class)cellClass;
- (void)registerCell:(Class)cellClass forState:(UITableViewState)state;

- (void)setCalculateContentCellHeightBlock:(CGFloat (^)(UITableViewCell *))calculateHeightBlock;
- (void)setCalculateListCellHeightBlock:(CGFloat (^)(NSIndexPath *))calculateHeightBlock;

- (void)registerLoadingCellClass:(Class)cellClass;
- (void)registerContentEmptyCellClass:(Class)cellClass;
- (void)registerListEmptyCellClass:(Class)cellClass;
- (void)registerContentErrorCellClass:(Class)cellClass;
- (void)registerListErrorCellClass:(Class)cellClass;
- (void)registerLoadMoreEmptyCellClass:(Class)cellClass;
- (void)registerLoadMoreErrorCellClass:(Class)cellClass;

- (NSUInteger)handleNumberOfSections;
- (NSUInteger)handleNumberOfRowsInSection:(NSUInteger)section;
- (UITableViewCell *)handleCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)handleHeightForCellAtIndexPath:(NSIndexPath *)indexPath;

@end
