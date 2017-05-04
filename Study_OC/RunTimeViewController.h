//
//  RunTimeViewController.h
//  Study_OC
//
//  Created by Madis on 2017/5/4.
//
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,RunTimeMethod){
    RunTimeMethod_changedMethod   = 0,
    RunTimeMethod_addProperty     = 1,
    RunTimeMethod_formatDataModel = 2,
    RunTimeMethod_addMethod       = 3
};

@interface RunTimeViewController : UIViewController

@property (nonatomic,assign) RunTimeMethod methodIndex;

@end
