//
//  Person.m
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import "Person.h"
#import <objc/message.h>
@implementation Dog
+ (instancetype)modelWithDictionary:(NSDictionary *)dict{
    id objc = [[self alloc] init];
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        //成员变量名
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [ivarName substringFromIndex:1];
        //成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        id value = dict[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class modelClass = NSClassFromString(ivarType);
            if (modelClass) {
                value = [modelClass modelWithDictionary:value];
            }
        }
        
        if ([value isKindOfClass:[NSArray class]]){
            NSArray *array = (NSArray *)value;
            for (int i = 0; i < array.count; i++) {
                id dictValue = array[i];
                //  TODO: 数组中自定义对象的解析
                if ([dictValue isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"dictValue:%@",dictValue);
                }
            }
            NSLog(@"");
        }
        
        if(value){
            [objc setValue:value forKey:key];
        }
        NSLog(@"key:%@,value:%@,ivarType:%@",key,value,ivarType);
        NSLog(@"");
    }
    return objc;
}

@end

@implementation Person

- (id)init
{
    self = [super init];
    if (self) {
        //log都为Person
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}

// !!!: 使用runtime解析dict为model
+ (instancetype)modelWithDictionary:(NSDictionary *)dict{
    id objc = [[self alloc] init];
    unsigned int count = 0;
    //获取类中所有成员变量
    //Ivar:成员变量,以下划线开头
    //Ivar *：指的是存放所有成员变量属性是ivar数组
    //count: 成员变量个数
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        //成员变量名
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        //处理成员变量,去除下划线
        NSString *key = [ivarName substringFromIndex:1];
        //成员变量类型
        NSString *ivarType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        ivarType = [ivarType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        id value = dict[key];
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class modelClass = NSClassFromString(ivarType);
            if (modelClass) {
                //对应的model也需要定义此方法,建议使用继承创建自定义model
                value = [modelClass modelWithDictionary:value];
            }
        }
        
        if ([value isKindOfClass:[NSArray class]]){
            NSArray *array = (NSArray *)value;
            for (int i = 0; i < array.count; i++) {
                id dictValue = array[i];
                //  TODO: 数组中自定义对象的解析
                if ([dictValue isKindOfClass:[NSDictionary class]]) {
                    NSLog(@"dictValue:%@",dictValue);
                }
            }
            NSLog(@"");
        }
        
        if(value){
            [objc setValue:value forKey:key];
        }
        NSLog(@"key:%@,value:%@,ivarType:%@",key,value,ivarType);
        NSLog(@"");
    }
    return objc;
}

//自定义run:方法实现
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
        // !!!: 动态添加run方法
        // class: 给哪个类添加方法
        // SEL: 添加哪个方法，即添加方法的方法编号
        // IMP: 方法实现 => 函数 => 函数入口 => 函数名（添加方法的函数实现（函数地址））
        // type: 方法类型，(返回值+参数类型) v:void,若是i则表示int     @:对象->self      ::表示SEL->_cmd    @:表示id(num)
        class_addMethod(self, sel, (IMP)runMethod, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

#pragma mark - KVC方法异常key值处理

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"undefinedKey:%@,value:%@",key,(NSString *)value);
}

#pragma mark - Name属性的setter和getter方法
- (void)setName:(NSString *)name{
    //虽然有setter方法,但是不会生成带下划线的属性和方法实现
//    _name = name;
    
    // !!!: 动态添加属性
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
