//
//  Person.h
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import <Foundation/Foundation.h>
@interface Dog : NSObject

@property (nonatomic,copy) NSString *dogName;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) NSInteger age;

@end

@interface Person : NSObject

//属性多余时不会抛出错误,调用赋值操作时会赋空值
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *pName;
@property (nonatomic,assign) NSInteger sex;
@property (nonatomic,assign) BOOL sex1;
@property (nonatomic,strong) NSArray *dogs;
@property (nonatomic,strong) NSArray *dogsArray;

@property (nonatomic,strong) Dog *dog;
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end
