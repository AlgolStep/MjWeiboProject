//
//  MjPlazaViewFlowLayout.m
//  PersonalWeibo
//
//  Created by qingyun on 14-6-23.
//  Copyright (c) 2014年 hnqingyun. All rights reserved.
//

#import "MjPlazaViewFlowLayout.h"

@interface MjPlazaViewFlowLayout ()
@property (nonatomic, assign)NSInteger sectionCount;

@end

@implementation MjPlazaViewFlowLayout


- (id)init
{
    if (self = [super init]) {
        self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    _sectionCount = [self.collectionView numberOfSections];
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allAttributes = [[NSMutableArray alloc]initWithCapacity:4];
    for (NSInteger i = 0; i < self.sectionCount; i ++) {
        for (NSInteger j = 0; j < [self.collectionView numberOfItemsInSection:i]; j ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
            [allAttributes addObject:attributes];
        }
    }
    return allAttributes;
}
@end
