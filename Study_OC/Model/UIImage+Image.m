//
//  UIImage+Image.m
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import "UIImage+Image.h"
#import <objc/message.h>

@implementation UIImage (Image)

/**
 在获取图片后作出相应操作时,
 1.使用继承类,重写方法.但是每次使用都要单独导入文件
 2.使用runtime,交换方法实现.(运行时遇到imageNamed:方法都会被替换为自定义的xl_imageNamed:方法)
 */

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
