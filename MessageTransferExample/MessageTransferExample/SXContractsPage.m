//
//  SXContractsPage.m
//  MessageTransferExample
//
//  Created by dongshangxian on 16/4/9.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "SXContractsPage.h"
#import "SXMessageTransfer.h"

@interface SXContractsPage ()

@end

@implementation SXContractsPage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [MsgTransfer listenMsg:@"SXMessageDsx" withInteraction:[SXMessageInteraction interactionWithObserver:self priority:@(600)] onReceiveAndProcessing:^id(id msgObject) {
        NSLog(@"<%@>一个可内部处理的block执行，优先级是600。 先把这个监听者的执行了，然后再执行发送者的block",@"SXContractsPage");
        if ([msgObject isKindOfClass:[NSDictionary class]]) {
            if ([msgObject[@"tip"] integerValue] > 1000) {
                return @"处理结果为成功";
            }else{
                return @"处理结果为失败";
            }
        }else{
            return @"参数不对";
        }
    }];
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
