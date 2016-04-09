//
//  SXHistoryPage.m
//  MessageTransferExample
//
//  Created by dongshangxian on 16/4/9.
//  Copyright © 2016年 Sankuai. All rights reserved.
//

#import "SXHistoryPage.h"
#import "SXMessageTransfer.h"

@interface SXHistoryPage ()

@end

@implementation SXHistoryPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MsgTransfer listenMsg:@"SXMessageDsx" observer:self onReceive:^(id msgObject) {
        NSLog(@"<%@>一个普通的block执行，因为没有设置优先级，那默认500",@"SXHistoryPage");
    }];
    
    // Do any additional setup after loading the view.
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
