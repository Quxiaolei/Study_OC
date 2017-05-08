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

@property (nonatomic,assign) NSInteger index;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) Person *p;
@end

@implementation RunTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //KVC设置数据值
    [self setValue:@1 forKey:@"index"];
    self.p = [Person new];
    [self setValue:@"李四" forKeyPath:@"p.name"];
    
    //通过KVC字典设置属性
    Person *p1 = [Person new];
    p1.name = @"a";
    NSDictionary *dict = @{@"name":@"张三",@"index":@100,@"p":p1};
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSLog(@"key:%@,value:%@",(NSString *)key,(NSString *)obj);
    }];
    [self setValuesForKeysWithDictionary:dict];

    //通过KVC取值
    Person *p2 = [Person new];
    p2.name = @"b";
    Person *p3 = [Person new];
    p3.name = @"c";
    NSArray *pArray = @[p1,p2,p3];
    //valueForKeyPath
    NSArray *nameArray = [pArray valueForKey:@"name"];
    
    //深层嵌套时无法通过KVC实现赋值
    //如果key值在类中无对应的属性值,在模型中找不到时就会报错
    NSDictionary *dict1 = @{@"name":@"张三丰",@"age":@1,@"dog":@{@"dogName":@"芝麻",@"age":@2}};
    Person *newPerson = [Person new];
    [newPerson setValuesForKeysWithDictionary:dict1];
        
    NSLog(@"");
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
            NSNumber *num = [NSNumber numberWithDouble:1.3];
            NSDictionary *dict = @{@"pName":@"张三丰",
                                   @"sex":num,
                                   @"sex1":@YES,
                                   @"dogs":@[@"1",@"2"],
                                   @"dog":@{@"name":@"芝麻",@"age":@10},
                                   @"dogsArray":@[@{@"name":@"芝麻糖",@"age":@20},@{@"name":@"芝麻糊",@"age":@30}],
                                   };
            Person *p = [Person modelWithDictionary:dict];
            NSLog(@"李磊");
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
