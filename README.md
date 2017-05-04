## runtime
#### 1. runtime的常见使用

使用时需要先导入`#import <objc/message.h>`

* ##### 动态交换两个方法
`class_getClassMethod`:获取类方法

 `class_getInstanceMethod`:获取实例方法

 `method_exchangeImplementations`:交换方法实现

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
 3. 使用runtime实现

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
