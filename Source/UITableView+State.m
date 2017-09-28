//
//  UITableView+State.m
//  GroupZonePoster
//
//  Created by 刘铎 on 26/09/2017.
//  Copyright © 2017 xxx. All rights reserved.
//

#import "UITableView+State.h"
#import <objc/runtime.h>

static NSString * const kLoadingCellIdentifier = @"kLoadingCellIdentifier";
static NSString * const kContentCellIdentifier = @"kContentCellIdentifier";
static NSString * const kContentEmptyCellIdentifier = @"kContentEmptyCellIdentifier";
static NSString * const kListEmptyCellIdentifier = @"kContentEmptyCellIdentifier";
static NSString * const kContentErrorCellIdentifier = @"kContentErrorCellIdentifier";
static NSString * const kListErrorCellIdentifier = @"kListErrorCellIdentifier";
static NSString * const kListCellIdentifier = @"kListCellIdentifier";
static NSString * const kLoadMoreEmptyIdentifier = @"kLoadMoreEmptyIdentifier";
static NSString * const kLoadMoreErrorIdentifier = @"kLoadMoreErrorIdentifier";

@implementation UITableView (State)

#pragma mark - 注册视图

- (void)setContentCell:(UIView *)cell {
    objc_setAssociatedObject(self, @selector(contentCell), cell, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UITableViewCell *)contentCell {
    UITableViewCell *cell = objc_getAssociatedObject(self, @selector(contentCell));
    NSAssert(cell, @"没有设置 ContentCell，请调用 `setContentCell:` 方法");
    return cell;
}

- (void)registerListCell:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kListCellIdentifier];
}

- (void)registerCell:(Class)cellClass forState:(UITableViewState)state {
    switch (state) {
        case UITableViewStateLoading:
            [self registerClass:cellClass forCellReuseIdentifier:kLoadingCellIdentifier];
            break;
            
        default:
            break;
    }
    
    self.stateDictionary[@(state)] = NSStringFromClass(cellClass);
}

- (void)registerLoadingCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kLoadingCellIdentifier];
}

- (void)registerContentEmptyCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kContentEmptyCellIdentifier];
}

- (void)registerListEmptyCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kListEmptyCellIdentifier];
}

- (void)registerContentErrorCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kContentErrorCellIdentifier];
}

- (void)registerListErrorCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kListErrorCellIdentifier];
}

- (void)registerLoadMoreEmptyCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kLoadMoreEmptyIdentifier];
}

- (void)registerLoadMoreErrorCellClass:(Class)cellClass {
    [self registerClass:cellClass forCellReuseIdentifier:kLoadMoreErrorIdentifier];
}

#pragma mark - 数据存取

- (NSMutableDictionary<NSNumber *, NSString *> *)stateDictionary {
    NSMutableDictionary *dictionary = objc_getAssociatedObject(self, @selector(stateDictionary));
    if (!dictionary) {
        dictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(stateDictionary), dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dictionary;
}

- (void)setStateDictionary:(NSDictionary<NSNumber *, NSString *> *)stateDictionary {
    objc_setAssociatedObject(self, @selector(stateDictionary), stateDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - 高度计算

- (void)setCalculateContentCellHeightBlock:(CGFloat (^)(UITableViewCell *))calculateHeightBlock {
    objc_setAssociatedObject(self, @selector(calculateContentCellHeightBlock), calculateHeightBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat (^)(UITableViewCell *))calculateContentCellHeightBlock {
    return objc_getAssociatedObject(self, @selector(calculateContentCellHeightBlock));
}

- (void)setCalculateListCellHeightBlock:(CGFloat (^)(NSIndexPath *))calculateHeightBlock {
    objc_setAssociatedObject(self, @selector(calculateListCellHeightBlock), calculateHeightBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CGFloat (^)(NSIndexPath *))calculateListCellHeightBlock {
    return objc_getAssociatedObject(self, @selector(calculateListCellHeightBlock));
}

#pragma mark - 状态切换

- (UITableViewState)currentState {
    return [objc_getAssociatedObject(self, @selector(currentState)) unsignedIntegerValue];
}

- (void)switchState:(UITableViewState)state {
    objc_setAssociatedObject(self, @selector(currentState), @(state), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    [self render];
}

- (void)render {
    [self reloadData];
    
    switch (self.currentState) {
        case UITableViewStateLoading:
            self.scrollEnabled = NO;
            break;
        case UITableViewStateContent:
        case UITableViewStateContentAndList:
        case UITableViewStateContentAndLoadMoreError:
        case UITableViewStateContentAndListError:
        case UITableViewStateContentAndListEmpty:
            self.scrollEnabled = YES;
            self.tableHeaderView = [self contentCell];
        case UITableViewStateContentAndLoadingList:
        case UITableViewStateContentAndLoadingMore: {
            self.scrollEnabled = YES;
            self.tableHeaderView = [self contentCell];
            UITableViewCell *loadingView = [self __loadingCell];
            loadingView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
            self.tableFooterView = loadingView;
        }
            break;
        case UITableViewStateContentAndLoadMoreEmpty: {
            self.scrollEnabled = YES;
            self.tableHeaderView = [self contentCell];
            UILabel *emptyLabel = [[UILabel alloc] init];
            emptyLabel.text = @"没有更多内容了";
            emptyLabel.textAlignment = NSTextAlignmentCenter;
            emptyLabel.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44);
            self.tableFooterView = emptyLabel;
        }
            break;
        default:
            self.scrollEnabled = YES;
            break;
    }
}

#pragma mark - 处理系统回调

- (NSUInteger)handleNumberOfSections {
    switch (self.currentState) {
        case UITableViewStateLoading:
        case UITableViewStateEmpty:
        case UITableViewStateError:
        case UITableViewStateContent:
            return 1;
        case UITableViewStateContentAndLoadingList:
            return 0;
        case UITableViewStateContentAndList:
            NSAssert(NO, @"不应该执行到这里");
        case UITableViewStateContentAndLoadingMore:
        case UITableViewStateContentAndLoadMoreEmpty:
        case UITableViewStateContentAndLoadMoreError:
        case UITableViewStateContentAndListError:
        case UITableViewStateContentAndListEmpty:
            return 1;
    }
}

- (NSUInteger)handleHeightForCellAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.currentState) {
        case UITableViewStateLoading:
        case UITableViewStateEmpty:
        case UITableViewStateError:
            return CGRectGetHeight(self.bounds);
        case UITableViewStateContent:
            return 0;
        case UITableViewStateContentAndLoadingList:
            return 44;
        case UITableViewStateContentAndList:
        case UITableViewStateContentAndLoadingMore:
        case UITableViewStateContentAndLoadMoreEmpty:
        case UITableViewStateContentAndLoadMoreError:
            return [self calculateListCellHeightBlock](indexPath);
        case UITableViewStateContentAndListEmpty:
        case UITableViewStateContentAndListError:
            return 50;
    }
}

- (NSUInteger)handleNumberOfRowsInSection:(NSUInteger)section {
    switch (self.currentState) {
        case UITableViewStateLoading:
        case UITableViewStateEmpty:
        case UITableViewStateError:
        case UITableViewStateContent:
        case UITableViewStateContentAndLoadingList:
            return 1;
        case UITableViewStateContentAndList:
            return 2;
        case UITableViewStateContentAndListEmpty:
        case UITableViewStateContentAndListError:
        case UITableViewStateContentAndLoadingMore:
        case UITableViewStateContentAndLoadMoreEmpty:
        case UITableViewStateContentAndLoadMoreError:
            return 1;
    }
}

- (UITableViewCell *)handleCellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath {
    switch (self.currentState) {
        case UITableViewStateLoading: {
            return [self __loadingCell];
        }
        case UITableViewStateError: {
            return [self __contentErrorCell];
        }
        case UITableViewStateContent: {
            return [self contentCell];
        }
        case UITableViewStateEmpty: {
            return [self __contentEmptyCell];
        }
        case UITableViewStateContentAndLoadingList: {
            return [self __loadingCell];
        }
        case UITableViewStateContentAndList: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
        case UITableViewStateContentAndListEmpty: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
        case UITableViewStateContentAndListError: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
        case UITableViewStateContentAndLoadingMore: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
        case UITableViewStateContentAndLoadMoreEmpty: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
        case UITableViewStateContentAndLoadMoreError: {
            return [self dequeueReusableCellWithIdentifier:kListCellIdentifier forIndexPath:indexPath];
        }
    }
    
    return [[UITableViewCell alloc] init];
}

#pragma mark - 私有方法：Cell 获取

- (UITableViewCell *)__loadingCell {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:kLoadingCellIdentifier];
    NSAssert(cell, @"没有注册 Loading 状态的 Cell，请调用 `registerLoadingCellClass:` 方法");
    return cell;
}

- (UITableViewCell *)__contentEmptyCell {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:kContentEmptyCellIdentifier];
    NSAssert(cell, @"没有注册 ContentEmpty 状态的 Cell，请调用 `registerContentEmptyCellClass:` 方法");
    return cell;
}

- (UITableViewCell *)__listEmptyCell {
    return nil;
}

- (UITableViewCell *)__loadMoreEmptyCell {
    return nil;
}

- (UITableViewCell *)__contentErrorCell {
    UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:kContentEmptyCellIdentifier];
    NSAssert(cell, @"没有注册 ContentEmpty 状态的 Cell，请调用 `registerContentEmptyCellClass:` 方法");
    return cell;
}

- (UITableViewCell *)__listErrorCell {
    return nil;
}

- (UITableViewCell *)__loadMoreErrorCell {
    return nil;
}

#pragma mark -

- (void)closeSelfSizing {
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
}

@end
