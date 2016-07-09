//
//  FirstViewControllerModel.m
//  Study_OC
//
//  Created by Madis on 16/7/9.
//
//

#import "FirstViewControllerModel.h"

@implementation FirstViewControllerModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.topTitleDict   = [NSMutableDictionary new];
        self.cellTitleArray = [NSMutableArray new];
        [self initDataSource];
    }
    return self;
}
- (void)initDataSource
{
    //分区0
    [self.topTitleDict setObject:@"数组排序" forKey:@"0"];
    [self.cellTitleArray addObject:@[@"sorted(Array)UsingComparator",
                                     @"sorted(Array)WithOptions",
                                     @"sorted(Array)UsingFunction",
                                     @"sorted(Array)UsingSelector",
                                     @"sorted(Array)UsingDescriptors"]];
    //分区1
    [self.topTitleDict setObject:@"数组筛选" forKey:@"1"];
    [self.cellTitleArray addObject:@[@"filtered(Array)UsingPredicate",
                                     @"sortedArrayUsingFunction",
                                     @"sortedArrayUsingSelector"]];
}
@end
