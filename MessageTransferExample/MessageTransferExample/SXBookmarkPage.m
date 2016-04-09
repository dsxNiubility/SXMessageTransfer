//
//  SXBookmarkPage.m
//  MessageTransferExample
//
//  Created by dongshangxian on 16/4/9.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "SXBookmarkPage.h"
#import "SXMessageTransfer.h"

@interface SXBookmarkPage ()

@end

@implementation SXBookmarkPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MsgTransfer listenMsg:@"SXMessageDsx" withInteraction:[SXMessageInteraction interactionWithObserver:self priority:@(300)] onReceive:^(id msgObject) {
            NSLog(@"<%@>一个普通的block执行，优先级是300",@"SXBookmarkPage");
    }];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)SendMsg:(UIButton *)sender {
    [MsgTransfer sendMsg:@"SXMessageDsx" withObject:@{@"tip":@"1314"} onReached:^(id msgObject) {
        
        NSLog(@"<%@>我(发送者)收到消息处理结果了，--结果是%@",@"SXBookmarkPage",msgObject);
        
    }];
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
