//
//  SYLifeManagerController.m
//  shan
//
//  Created by aDu on 2016/12/5.
//  Copyright © 2016年 DuKaiShun. All rights reserved.
//

#import "SYLifeManagerController.h"
#import "SYLifeManagerCell.h"
#import "SYLifeManagerModel.h"
#import "SYLifeManagerHeaderView.h"
#import "SYLIfeManagerFooterView.h"
#import "Header.h"

#define K_Cell @"cell"
#define K_No_Cell @"noCell"
#define K_Head_Cell @"headCell"
#define K_Foot_Cell @"footCell"
@interface SYLifeManagerController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *groupArray;

@property (nonatomic, strong) SYLifeManagerLayout *flowLayout;
@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态

@property (nonatomic, strong) UIButton *rightItemBtn; //右边的按钮
@property (nonatomic, strong) UILabel *messageLabel; //删除完毕时

@end

@implementation SYLifeManagerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"生活应用";
    //添加右边的按钮
    self.rightItemBtn = [self addRightBarButtonItem:@"管理"];
    [self.rightItemBtn setTitle:@"完成" forState:UIControlStateSelected];
    [self.rightItemBtn setTitle:@"管理" forState:UIControlStateNormal];
    for (int i = 0; i < 6; i++) {
        SYLifeManagerModel *model = [[SYLifeManagerModel alloc] init];
        model.title = [NSString stringWithFormat:@"推荐%@", @(i)];
        [self.dataArray addObject:model];
        [self.groupArray addObject:model];
    }
    for (int i = 0; i < 4; i++) {
        SYLifeManagerModel *model = [[SYLifeManagerModel alloc] init];
        model.title = [NSString stringWithFormat:@"生活%@", @(i)];
        [self.groupArray addObject:model];
    }
    [self.view addSubview:self.collectionView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - SYLifeManagerDelegate

//处于编辑状态
- (void)didChangeEditState:(BOOL)inEditState
{
    self.inEditState = inEditState;
    self.rightItemBtn.selected = inEditState;
    for (SYLifeManagerCell *cell in self.collectionView.visibleCells) {
        cell.inEditState = inEditState;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        SYLifeManagerModel *model;
        BOOL exist = NO;
        if (indexPath.section == 0) {
            model = self.dataArray[indexPath.row];
        } else {
            model = self.groupArray[indexPath.row];
            if ([self.dataArray containsObject:model]) {
                exist = YES;
            }
        }
        [cell setModel:model indexPaht:indexPath exist:exist];
    }
}

#pragma mark - 右边的编辑按钮方法

- (void)rightBarButtonItemAction:(UIButton *)barButton
{
    if (!self.inEditState) { //点击了管理
        self.inEditState = YES;
        self.collectionView.allowsSelection = NO;
    } else { //点击了完成
        self.inEditState = NO;
        self.collectionView.allowsSelection = YES;
    }
    [self.flowLayout setInEditState:self.inEditState];
}

#pragma mark - 点击button的方法

- (void)btnClick:(UIButton *)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:currentPoint];
    if (indexPath.section == 0 && indexPath != nil) { //点击移除
        [self.collectionView performBatchUpdates:^{
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            [self.dataArray removeObjectAtIndex:indexPath.row]; //删除
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }];
    } else if (indexPath != nil) { //点击添加
        //在第一组最后增加一个
        [self.dataArray addObject:self.groupArray[indexPath.row]];
         NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:self.dataArray.count - 1 inSection:0];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
        } completion:^(BOOL finished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }];
    }
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.dataArray.count;
    } else {
        return self.groupArray.count;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

//创建cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SYLifeManagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:K_Cell forIndexPath:indexPath];
    [cell setDataAry:self.dataArray groupAry:self.groupArray indexPath:indexPath];
    //是否处于编辑状态，如果处于编辑状态，出现边框和按钮，否则隐藏
    cell.inEditState = self.inEditState;
    [cell.button addTarget:self action:@selector(btnClick:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - 点击collectionView的方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.inEditState) { //如果不在编辑状态
        
    }
}

#pragma mark - HeaderAndFooter

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        SYLifeManagerHeaderView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:K_Head_Cell forIndexPath:indexPath];
        if (indexPath.section == 0) {
            headView.headLabel.text = @"我的应用";
        } else {
            headView.headLabel.text = @"便捷生活";
        }
        return headView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
        SYLIfeManagerFooterView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:K_Foot_Cell forIndexPath:indexPath];
        return footView;
    }
    return nil;
}

//头视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (self.dataArray.count == 0) {
        if (section == 0) {
            CGFloat width = (Screen_Width - 80) / 4;
            self.messageLabel.frame = CGRectMake(0, 30, Screen_Width, width);
            [self.collectionView addSubview:self.messageLabel];
            return CGSizeMake(Screen_Width, 25 + width);
        } else {
            return CGSizeMake(Screen_Width, 25);
        }
    } else {
        [self.messageLabel removeFromSuperview];
        return CGSizeMake(Screen_Width, 25);
    }
}

//尾视图
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return CGSizeMake(Screen_Width, 10);
    } else {
        return CGSizeMake(Screen_Width, 0.01);
    }
}

#pragma mark - init

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //给集合视图注册一个cell
        [_collectionView registerClass:[SYLifeManagerCell class] forCellWithReuseIdentifier:K_Cell];
        //注册一个区头视图
        [_collectionView registerClass:[SYLifeManagerHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:K_Head_Cell];
        //注册一个区尾视图
        [_collectionView registerClass:[SYLIfeManagerFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:K_Foot_Cell];
    }
    return _collectionView;
}

- (SYLifeManagerLayout *)flowLayout
{
    if (!_flowLayout) {
        CGFloat width = (Screen_Width - 80) / 4;
        _flowLayout = [[SYLifeManagerLayout alloc] init];
        _flowLayout.delegate = self;
        //设置每个图片的大小
        _flowLayout.itemSize = CGSizeMake(width, width);
        //设置滚动方向的间距
        _flowLayout.minimumLineSpacing = 10;
        //设置上方的反方向
        _flowLayout.minimumInteritemSpacing = 0;
        //设置collectionView整体的上下左右之间的间距
        _flowLayout.sectionInset = UIEdgeInsetsMake(15, 20, 20, 20);
        //设置滚动方向
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataArray;
}

- (NSMutableArray *)groupArray
{
    if (_groupArray == nil) {
        _groupArray = [NSMutableArray arrayWithCapacity:1];
    }
    return _groupArray;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:K_LittleFont_Size];
        _messageLabel.textColor = [UIColor sy_grayColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.text = @"您还未添加任何应用\n长按下面的应用可以添加";
    }
    return _messageLabel;
}

@end