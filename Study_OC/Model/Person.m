//
//  Person.m
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import "Person.h"
#import <objc/message.h>

@implementation Person

void runMethod(id self, SEL _cmd, NSNumber *meter) {
    NSLog(@"跑了%@米", meter);
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    NSLog(@"");
    return YES;
}

/**
 动态添加方法,处理未实现
 只要对象调用了一个未实现的方法就会调用这个方法,进行处理
 
 任何方法默认都有两个隐式参数,self,_cmd（当前方法的方法编号）
 @param sel 方法编号
 @return
 */
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    // [NSStringFromSelector(sel) isEqualToString:@"run"];
    if (sel == NSSelectorFromString(@"run:")) {
        // 动态添加run方法
        // class: 给哪个类添加方法
        // SEL: 添加哪个方法，即添加方法的方法编号
        // IMP: 方法实现 => 函数 => 函数入口 => 函数名（添加方法的函数实现（函数地址））
        // type: 方法类型，(返回值+参数类型) v:void,若是i则表示int     @:对象->self      ::表示SEL->_cmd    @:表示id(num)
        class_addMethod(self, sel, (IMP)runMethod, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

#pragma mark - Name属性的setter和getter方法
- (void)setName:(NSString *)name{
    //虽然有setter方法,但是不会生成带下划线的属性和方法实现
//    _name = name;
    
    // objc_setAssociatedObject（将某个值跟某个对象关联起来，将某个值存储到某个对象中）
    // object:给哪个对象添加属性
    // key:属性名称
    // value:属性值
    // policy:保存策略
    objc_setAssociatedObject(self, @"name", name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    NSLog(@"");
}

- (NSString *)name{
    //
//    return @"1";
    //objc_setAssociatedObject (获取某个key在对象中的对应值)
    return objc_getAssociatedObject(self, @"name");
}

@end
