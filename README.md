# SXMessageTransfer
原生通知中心的扩展，可以设置优先级，回调事件，同步异步执行

---

需求驱动中发现iOS的NotificationCenter有很多功能无法实现，于是对其进行了一层包装。这个包装在于手动管理观察者栈和监听者期望执行的事件，因此可以为其添加了很多新增的功能，将其命名为MessageTransfer。


####具体扩展的功能有如下几点：

1. 可以自行控制通知的执行方式是异步执行还是同步执行<br /> <br />
2. 可以在添加观察者时直接用block写上收到时要执行的事件<br /> <br />
3. 可以在发送通知时直接用block写上送达时要执行的事件<br /> <br />
4. 可以给上面说的事件设置优先级，严格按照优先级执行，优先级相同则依照添加顺序<br /> <br />
5. 可以添加可处理的block<br >
  (这里比较难理解，可以理解成观察者的那个block可以有返回值，返回值作为发送者那个block的入参。假设一个场景 登录管理器监听着登录的通知，收到通知后进行判断和处理然后将结果返回。 那在登录界面就可以直接拿到点击登录后的结果进行操作了。）<br /> <br />
6. 每个页面不用手动移除观察者了。（前提是需要在父类稍作配置）


####使用前后的对比
_原生写法 :_

	// ********普通做法   
	// 1.一边发送  (这个通知的名字命名还需要注意统一)
	[[NSNotificationCenter defaultCenter]postNotificationName:@"XXX" object:XXX userInfo:XXX];
	// 2.另一边接收
	[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(xxx:) name:@"XXX" object:XXX]
	// 3.还要手动去实现一个方法
	XXX:
	// 4.在自己方法的delloc时还要记得将观察者移除，否则会导致崩溃。
	delloc:  [NSNotificationCenter defaultCenter]removeObserver


_SXMessageTransfer :_<br><br>
最普通的写法

	// ********观察者A （普通监听）
	[MsgTransfer listenMsg:@"DSXDSX"  onReceive:^(id msgObject) {
    	MTLog(@"*******最普通的监听回调,参数内容%@",msgObject);
	}]; 
	
复杂操作

	// ********观察者B （复杂监听）
	[MsgTransfer listenMsg:@"DSXDSX" withInteraction:[SXMessageInteraction 	interactionWithObserver:self priority:@(700)] 	onReceiveAndProcessing:^id (id dict) {
    	MTLog(@"*******优先级是700的block执行-参数%@",dict);
    // 假设对传入的dict做了处理后返回一个字典
    BOOL loginSuccess = [dict[@"pwd"] isEqualToString:@"123456"] && [dict[@"account"] isEqualToString:@"admin"];
    	return @{@"result":(loginSuccess?@"登录成功，即将跳转...":@"账号或密码有个不对")};
	}];
   
	// ********发送者 （同步执行）
	[MsgTransfer sendMsg:@"DSXDSX" withObject:@{@"account":@"admin",@"pwd":@"123456"} type:SXMessageExcuteTypeSync onReached:^(id obj) {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        MTLog(@"一个内部处理后的回调  *****%@",obj[@"result"]);
    }else{
       	 MTLog(@"一个普通者的回调  *****消息ID%@",obj);
    	}
	}];

具体实现也可以参照demo程序，里面写的也很清楚
