//
//  FirstViewControllerModel.h
//  Study_OC
//
//  Created by Madis on 16/7/9.
//
//

#import <Foundation/Foundation.h>

@interface FirstViewControllerModel : NSObject
@property (nonatomic,strong) NSMutableDictionary <NSString *,NSString *> *topTitleDict;
@property (nonatomic,strong) NSMutableArray <NSArray <NSString *> *> *cellTitleArray;

@end
