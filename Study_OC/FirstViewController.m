//
//  FirstViewController.m
//  Study_OC
//
//  Created by Madis on 16/7/9.
//
//

#import "FirstViewController.h"
#import "FirstViewControllerModel.h"

@interface MUser : NSObject
@property (nonatomic,assign) NSInteger age;
@end
@implementation MUser
@end

static NSString *const cellIdentifier = @"mainTableView";
@interface FirstViewController ()
<UITableViewDelegate,
UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *mainTableView;
@property (strong, nonatomic) FirstViewControllerModel *model;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.model = [[FirstViewControllerModel alloc] init];
    [self initView];
}

- (void)initView
{
//    self.mainTableView.backgroundColor = [UIColor lightGrayColor];
    [self.mainTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
}
#pragma mark - tableView dataSource & delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.model.cellTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.model.cellTitleArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
//    if (0 == indexPath.row%2) {
//        cell.backgroundColor = [UIColor lightGrayColor];
//    }else{
//        cell.backgroundColor = [UIColor grayColor];
//    }
    cell.textLabel.text = self.model.cellTitleArray[indexPath.section][indexPath.row];
//    [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.model.topTitleDict objectForKey:[NSString stringWithFormat:@"%ld",section]];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return CGFLOAT_MIN;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"-----tableViewDidSelect:%@",indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (0 == indexPath.section) {
        switch (indexPath.row) {
            case 0:
                [self sortedArrayUsingComparator];
                break;
            case 1:
                [self sortedArrayWithOptions];
                break;
            case 2:
                [self sortedArrayUsingFunction];
                break;
            case 3:
                [self sortedArrayUsingSelector];
                break;
            case 4:
                [self sortedArrayUsingDescriptors];
                break;
            default:
                break;
        }
    }else if (1 == indexPath.section){
        switch (indexPath.row) {
            case 0:
                [self predicate];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - something interesting

- (void)sortedArrayUsingComparator
{
    NSArray *sortArray = [[NSArray alloc] initWithObjects:@"4",@"3",@"1",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"4",nil];
    
    NSComparator cmptr = ^(id obj1, id obj2){
        if ([obj1 integerValue] > [obj2 integerValue]) {
            //降序
            return (NSComparisonResult)NSOrderedDescending;
        }else if ([obj1 integerValue] < [obj2 integerValue]) {
            //升序
            return (NSComparisonResult)NSOrderedAscending;
        }else return (NSComparisonResult)NSOrderedSame;
    };
    
    //sortedArrayUsingComparator
    NSArray *array =
//    [sortArray sortedArrayUsingComparator:cmptr];
    [sortArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber*numberObj1 = [NSNumber numberWithInteger:[obj1 integerValue]];
        NSNumber*numberObj2 = [NSNumber numberWithInteger:[obj2 integerValue]];
        return [numberObj1 compare:numberObj2];
    }];
    NSLog(@"\nsortArray:%@,\n:array%@",sortArray,array);
}

- (void)sortedArrayWithOptions
{
    NSArray *sortArray = [[NSArray alloc] initWithObjects:@"4",@"3",@"1",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"4",nil];
    //sortedArrayWithOptions:usingComparator:
    NSArray *array = [[sortArray copy] sortedArrayWithOptions:NSSortStable usingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber*numberObj1 = [NSNumber numberWithInteger:[obj1 integerValue]];
        NSNumber*numberObj2 = [NSNumber numberWithInteger:[obj2 integerValue]];
        return [numberObj1 compare:numberObj2];
    }];
    NSLog(@"\nsortArray:%@,\n:array%@",sortArray,array);
}

NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2){
        return (NSComparisonResult) NSOrderedAscending;
    }else if (v1 > v2){
        return (NSComparisonResult) NSOrderedDescending;
    }else{
        return (NSComparisonResult)NSOrderedSame;
    }
}
- (void)sortedArrayUsingFunction
{
    NSArray *sortArray = [[NSArray alloc] initWithObjects:@"4",@"3",@"1",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"4",nil];
    //sortedArrayUsingFunction:context
    NSArray *array = [sortArray sortedArrayUsingFunction:intSort context:nil];
    NSLog(@"\nsortArray:%@,\narray:%@",sortArray,array);
}

- (void)sortedArrayUsingSelector
{
    NSArray *sortArray =
    [[NSArray alloc] initWithObjects:@"e",@"j",@"h",@"d",@"f",@"a",@"m",@"k",@"b",@"l",@"n",@"c",@"g",@"i",nil];
//    [[NSArray alloc] initWithObjects:@4,@3,@1,@7,@8,@2,@6,@5,@13,@15,@12,@20,@28,@4,nil];
//    [[NSArray alloc] initWithObjects:@"4",@"3",@"1",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"4",nil];
    //sortedArrayUsingSelector
    //compare:系统比较方法,可以对字符串数组排序
    //数字当作字符串比较后排序结果为:1, 12, 13, 15, 2, 20, 28, 3, 4, 4, 5, 6, 7, 8
    NSArray *array = [sortArray sortedArrayUsingSelector:@selector(compare:)];
    
    //此方法无返回值，也不能修改原数组，不带参数。
//    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
//    [[self.view subviews] makeObjectsPerformSelector:@selector(setBackgroundColor:) withObject:[UIColor redColor]];
    
    NSLog(@"\nsortArray:%@,\narray:%@",sortArray,array);
}

/*!
 *  @author xiaolei, 16-07-09 19:07:46
 *
 *  按照对象中的属性进行排序
 */
- (void)sortedArrayUsingDescriptors
{
    NSMutableArray *sortArray = [NSMutableArray new];
    NSMutableString *sortArrayString = [NSMutableString new];
    for(int i = 0;i < 10;i++){
        MUser *user = [MUser new];
        user.age = arc4random()%99+1;
        [sortArray addObject:user];
        [sortArrayString appendString:[NSString stringWithFormat:@"%ld,",(long)user.age]];
    }
    //user.age
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:YES];
    //sortedArrayUsingDescriptors
    NSArray *array = [[sortArray copy] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSMutableString *arrayString = [NSMutableString new];
    for (MUser *user in array) {
        [arrayString appendString:[NSString stringWithFormat:@"%ld,",(long)user.age]];
    }
    NSLog(@"\nsortArray:%@\narray:%@",sortArrayString,arrayString);
}

- (void)predicate
{
    NSArray *filterArray = [[NSArray alloc] initWithObjects:@"15",@"3",@"4",@"7",@"8",@"2",@"6",@"5",@"13",@"15",@"12",@"20",@"28",@"4",nil];
    //TODO: 谓词的语法
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"SELF == %@",[NSString stringWithFormat:@"%d",15]];
    //filteredArrayUsingPredicate
    NSArray *array=[filterArray filteredArrayUsingPredicate:predicate];
    NSLog(@"\nfilterArray:%@,\narray:%@",filterArray,array);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
