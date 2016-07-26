//
//  ShareViewController.m
//  ShareMenu
//
//  Created by Madis on 16/7/26.
//
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

static NSInteger const maxCharactersAllowed =  140; //手动设置字符数上限
static NSString const *sc_uploadURL = @"http://requestb.in/1b8fkya1"; //http://requestb.in申请

@implementation ShareViewController

//监测文本框的内容变化，输入文字时会调用该方法，返回 NO 时 Post 按钮不可用。
- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    
    NSInteger length = self.contentText.length;
    self.charactersRemaining = @(maxCharactersAllowed - length);
    if ([self.charactersRemaining integerValue] >= maxCharactersAllowed) {
        return NO;
    }
    return YES;
}

- (void)fetchItemDataAtBackground
{
    //后台获取
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *inputItems = self.extensionContext.inputItems;
        NSExtensionItem *item = inputItems.firstObject;//无论多少数据，实际上只有一个 NSExtensionItem 对象
        for (NSItemProvider *provider in item.attachments) {
            //completionHandler 是异步运行的
            NSString *dataType = provider.registeredTypeIdentifiers.firstObject;//实际上一个NSItemProvider里也只有一种数据类型
            if ([dataType isEqualToString:@"public.image"]) {
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(UIImage *image, NSError *error){
                    //collect image...
                }];
            }else if ([dataType isEqualToString:@"public.plain-text"]){
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSString *contentText, NSError *error){
                    //collect text...
                }];
            }else if ([dataType isEqualToString:@"public.url"]){
                [provider loadItemForTypeIdentifier:dataType options:nil completionHandler:^(NSURL *url, NSError *error){
                    //collect url...
                }];
            }else
                NSLog(@"don't support data type: %@", dataType);
        }
    });
}
//用于获取封装的数据类型，咋看之下非常别扭。需要提供 Uniform Type Identifier 简称 UTI 格式的标志符来找出数据类型。
- (BOOL)hasItemConformingToTypeIdentifier:(NSString *)typeIdentifier
{
    return YES;
}
//指定格式来获取数据，异步执行。
- (void)loadItemForTypeIdentifier:(NSString *)typeIdentifier options:(NSDictionary *)options completionHandler:(NSItemProviderCompletionHandler)completionHandler
{
    
}
//点击 Post 按钮后会调用
- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    // Upload asynchronously/后台异步上传内容
    NSExtensionItem *inputItem = self.extensionContext.inputItems.firstObject;
    NSExtensionItem *outputItem = [inputItem copy];
    outputItem.attributedContentText = [[NSAttributedString alloc] initWithString:self.contentText attributes:nil];
    // Complete this implementation by setting the appropriate value on the output item.
    NSArray *outputItems = @[outputItem];
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    //向载体应用反馈结果并且让分享界面消失
    [self.extensionContext completeRequestReturningItems:outputItems completionHandler:^(BOOL expired) {
        NSLog(@"分享完成啦");
    }];
}

//在didSelectPost方法的最后调用，用于向载体应用反馈结果并且准备结束扩展的运行。
- (void)completeRequestReturningItems:(NSArray *)items completionHandler:(void (^)(BOOL expired))completionHandler
{
    
}

//点击 Cancel 按钮后会调用
- (void)didSelectCancel
{
    
}

//在didSelectCancel中调用，如果你需要反馈错误信息，可以重写该方法
- (void)cancelRequestWithError:(NSError *)error
{
    
}


- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    return @[];
}

@end
