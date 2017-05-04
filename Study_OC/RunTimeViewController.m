//
//  RunTimeViewController.m
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import "RunTimeViewController.h"
#import "Person.h"
//不需要导入
//#import "UIImage+Image.h"
@interface RunTimeViewController ()

@end

@implementation RunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    switch (self.methodIndex) {
        case RunTimeMethod_changedMethod:
        {
            //交换方法实现
            /**
             在获取图片后作出相应操作时,
             1.使用继承类,重写方法.但是每次使用都要单独导入文件
             2.使用runtime,交换方法实现.(运行时遇到imageNamed:方法都会被替换为自定义的xl_imageNamed:方法)
             */
            UIImage *image = [UIImage imageNamed:@"红包"];
        }
            break;
        case RunTimeMethod_addProperty:
        {
            //动态添加属性
            //在类的扩展中,只能添加方法不能添加属性.但是可以使用runtime实现.
            Person *p = [Person new];
            p.name = @"张三";
            NSLog(@"person.name:%@",p.name);
            NSLog(@"");
        }
            break;
        case RunTimeMethod_formatDataModel:
        {
            
        }
            break;
        case RunTimeMethod_addMethod:
        {
            //动态添加方法
            Person *p = [[Person alloc] init];
            [p performSelector:@selector(run:) withObject:@10];
        }
            break;
            
        default:
            break;
    }
    NSLog(@"");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
