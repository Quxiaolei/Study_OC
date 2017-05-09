## runtime

基本概念:

`objc_msgSend`:OC中调用方法,其实就是给某个对象发消息.对象的区分使用消息ID.`IMP`类似函数指针,指向具体的`Method`实现.通过`selector`可以找到对应的`IMP`.

`objc_msgSend()`,`objc_msgSend_stret`,`objc_msgSendSuper`,`objc_msgSendSuper_stret`.含`super`是消息传递给超类,含`stret`的消息返回值是数据结构,不是简单类型

`SEL`:`selector`是方法选择器,表示方法的ID,ID的数据结构是`SEL`.可以在runtime时使用`sel_registerName`创建方法类型.

扩展:

```objective-c
@implementation Son : NSObject
- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}
@end
//输出log:Son
```
`super`只是一个编译器指示符,当编译器看到`super`时会让当前对象去调用其父类的方法.实质上还是当前对象在调用

`[self class]`对应`id objc_msgSend(id self, SEL op, ...)`,

`[super class]`对应`id objc_msgSendSuper(struct objc_super *super, SEL op, ...)`,
```objective-c
struct objc_super {
 //receiver 代表当前对象,也就是self
 __unsafe_unretained id receiver;
 //记录当前类的父类
 __unsafe_unretained Class super_class;
 };
 ```
调用时,从当前类的父类查找方法,找到方法后内部使用` objc_msgSend(objc_super->receiver, @selector(class))`


#### 1. runtime的常见使用

使用时需要先导入`#import <objc/message.h>`

* ##### 动态交换两个方法
`class_getClassMethod`:获取类方法

 `class_getInstanceMethod`:获取实例方法

 `method_exchangeImplementations`:交换方法实现

`class_addMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)`:增加方法

`class_replaceMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)`:替换方法实现,`class_replaceMethod(toolClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod))`

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];
    /**
     在获取图片后作出相应操作时,
     1.使用继承类,重写方法.但是每次使用都要单独导入文件
     2.使用runtime,交换方法实现.(运行时遇到imageNamed:方法都会被替换为自定义的xl_imageNamed:方法)
     */
    UIImage *image = [UIImage imageNamed:@"红包"];
}

@implementation UIImage (Image)

//在调用系统的imageNamed:方法前就替换两个方法的实现
+ (void)load{
    //1. 获取imageNamed方法
    //class_getClassMethod 获取某个类的方法
    Method imageNamedMethod = class_getClassMethod(self, @selector(imageNamed:));

    //2. 获取xl_imageNamedMethod方法
    Method xl_imageNamedMethod = class_getClassMethod(self, @selector(xl_imageNamed:));

    //3. 交换方法实现
    method_exchangeImplementations(imageNamedMethod, xl_imageNamedMethod);
}

/**
 不存在死循环
 调用 imageNamed => xl_imageNamed
 调用 xl_imageNamed => imageNamed

 交换方法实现后,imageNamed:方法的实现 === xl_imageNamed:方法的实现,
 内层的语句,UIImage *image = [UIImage xl_imageNamed:name];方法调用不会改变
 */
+ (UIImage *)xl_imageNamed:(NSString *)name {
    UIImage *image = [UIImage xl_imageNamed:name];
    if (image) {
        NSLog(@"runtime添加额外功能--加载成功");
    } else {
        NSLog(@"runtime添加额外功能--加载失败");
    }
    return image;
}
@end

//调用imageNamed:方法时,实际调用代码为:
+ (UIImage *)imageNamed:(NSString *)name {
  //原方法的实现中方法的调用不会改变
    UIImage *image = [UIImage xl_imageNamed:name];
    if (image) {
        NSLog(@"runtime添加额外功能--加载成功");
    } else {
        NSLog(@"runtime添加额外功能--加载失败");
    }
    return image;
}
```

* ##### 动态添加属性(常用于类扩展中)
类别中只能添加方法,不能添加属性.但是可以使用runtime实现.

 在类别中定义属性,会生成对应的`setter`和`getter`方法,但是没有对应的带下划线的属性和方法实现.

 `objc_setAssociatedObject(<#id object#>, <#const void *key#>, <#id value#>, <#objc_AssociationPolicy policy#>)`:给对象添加属性,即将某个属性值和对象进行绑定.object对象,key属性名,value属性值,policy保存策略

 `objc_getAssociatedObject(<#id object#>, <#const void *key#>)`:获取对象的某个属性值

```objective-c
//调用
//在类的扩展中,只能添加方法不能添加属性.但是可以使用runtime实现.
Person *p = [Person new];
p.name = @"张三";
NSLog(@"person.name:%@",p.name);

@implementation Person

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
```
* ##### 实现字典和模型间的自动转换
字典转Model常用的方法:
 1. 手动赋值
 2. KVC方式转换:但是必须保证model中的属性和字典中的key值一一对应,可以重写`setValue:forUndefinedKey:`方法避免不对应报错

   KVC(`key-value-coding`)即键值编码.KVC需要实现`NSKeyValueCoding`协议,他不通过`setter`和`getter`方法而是使用属性名称字符串(`key`)间接的访问属性.

   常见方法有:`setValue:forKey:`,`setValue:forKeyPath:`(支持内部的点语法访问属性),`valueForKey`,`valueForKeyPath`

   ```objective-c
   @property (nonatomic,assign) NSInteger index;
   //KVC设置数据值
   [self setValue:@1 forKey:@"index"];
   ```
   先去类中找有没有`setIndex`方法,若有就直接调用`[self setIndex:value]`,

   去找类中有没有`index`属性,若有直接进行属性赋值`index=value`,

   去找类中有没有`_index`属性,如有直接进行属性赋值`_index=value`,

   找不到就通过`valueForUndefinedKey:`方法报错

   KVO(`key-value-observer`)即键值观察:通过一个`key`值找到某个属性并来监听其值变化,当属性发生变化时会自动通知观察者(观察者记得要在`dealloc`方法中移除)

 3. 使用runtime实现(**** MJExtension ****)

     利用运行时特性,遍历模型的所有属性.根据属性名称在数据中查找`key`对应的值,并给属性赋值.

     主要存在的特殊情况:模型的属性和数据中的`key`值不对应(模型属性值在数据中找不到对应值会抛出异常,需要手动调用`setValue:forUndefinedKey:`处理),模型的嵌套,数组中元素为模型

     `class_copyIvarList`:获取类中所有属性和变量(以下划线开头)

     `class_copyPropertyList`:获取类的所有属性

     `class_copyMethodList`:获取方法列表

     `class_copyProtocolList`:获取协议列表

     `Ivar`:成员变量(以下划线开头)和属性

     `ivar_getName`:获取成员变量名

     `property_getName`:获取属性名

     `protocol_getName`:获取协议名

 ```objective-c
 //调用
 NSNumber *num = [NSNumber numberWithDouble:1.3];
 NSDictionary *dict = @{@"pName":@"张三丰",
                        @"sex":num,
                        @"sex1":@YES,
                        @"dogs":@[@"1",@"2"],
                        @"dog":@{@"name":@"芝麻",@"age":@10},
                        @"dogsArray":@[@{@"name":@"芝麻糖",@"age":@20},@{@"name":@"芝麻糊",@"age":@30}],
                        };
 Person *p = [Person modelWithDictionary:dict];

 // Person.h
 //属性多余时不会抛出错误,调用赋值操作时会赋空值
 @property (nonatomic,copy) NSString *name;
 @property (nonatomic,copy) NSString *pName;
 @property (nonatomic,assign) NSInteger sex;
 @property (nonatomic,assign) BOOL sex1;
 @property (nonatomic,strong) NSArray *dogs;
 @property (nonatomic,strong) Dog *dog;
 @property (nonatomic,strong) NSArray *dogsArray;

 + (instancetype)modelWithDictionary:(NSDictionary *)dict;

 // Person.m
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
 ```

* ##### 动态添加方法
当一个类中方法特别多,加载类文件到内存中就会比较耗时,耗费资源.我们可以动态添加方法节省内存资源,真正的实现`懒加载`

 `resolveInstanceMethod`:处理实例方法

 `resolveClassMethod`:处理类方法

 `class_addMethod(<#__unsafe_unretained Class cls#>, <#SEL name#>, <#IMP imp#>, <#const char *types#>)`:动态添加方法,cls对象,name方法名/方法id,imp方法实现,types方法类型

 v:void,若是i则表示int

 @:对象,一般为self

 ::表示SEL->_cmd

 @:表示id(num,str等)

```objective-c
- (void)viewDidLoad {
    [super viewDidLoad];   
    Person *p = [[Person alloc] init];
    // 默认person，没有实现run:方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [p performSelector:@selector(run:) withObject:@10];
}

@implementation Person
// 没有返回值,1个参数
// void,(id,SEL)
void runMethod(id self, SEL _cmd, NSNumber *meter) {
    NSLog(@"跑了%@米", meter);
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
        // type: 方法类型，(返回值+参数类型) v:void,若是i则表示int     @:对象->self      :表示SEL->_cmd    @:表示id(num)
        class_addMethod(self, sel, (IMP)runMethod, "v@:@");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}
@end
```

#### 2.总览

runtime的使用场景:

[Runtime Method Swizzling开发实例汇总（持续更新中）](http://www.jianshu.com/p/f6dad8e1b848)

##### Extensions:

[iOS8扩展插件开发配置](http://blog.csdn.net/phunxm/article/details/42715145)

[iOS 8 Extensions](http://www.cnblogs.com/xdream86/p/3855932.html)

[App Extension编程指南（iOS8/OS X v10.10）中文版](http://www.cocoachina.com/ios/20141023/10027.html)

[iOS8中添加的extensions总结（一）——今日扩展](http://www.cnblogs.com/jackma86/p/5002899.html)

[iOS8中添加的extensions总结（二）——分享扩展](http://www.cnblogs.com/jackma86/p/5011379.html)

[iOS8中添加的extensions总结（三）——图片编辑扩展](http://www.cnblogs.com/jackma86/p/5018512.html)

[iOS8中添加的extensions总结（四）——Action扩展](http://www.cnblogs.com/jackma86/p/5023800.html)

[iOS 8 分享扩展(Share Extension)入门](http://www.jianshu.com/p/99d4ec43fd65)

[iOS8 Day-by-Day-- Day2 -- 分享应用扩展](http://www.devtalking.com/articles/ios8-day-by-day-day2-sharing-extension/)

---
[使用NSURLSession进行上传下载](http://blog.csdn.net/chaoyuan899/article/details/35985815)
