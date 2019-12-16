//
//  JCARKitViewController.m
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/13.
//

#import "JCARKitViewController.h"
#import "JCRouter.h"

@interface JCARKitViewController ()

@end

@implementation JCARKitViewController

/*
例:
输出一个JCARKitViewController组件exportInterface接口, 查看JDRouter.h头文件方法说明
JCRouter_Extern_Methon(JCARKitViewController, exportInterface, arg, callback) {
        
    return nil;
}
*/
JCRouter_Extern_Methon(JCARKitViewController, exportInterface, arg, callback) {
    NSLog(@" JC ------> ARKit 调用成功");
    JCARKitViewController *vc = [[JCARKitViewController alloc] init];
    return vc;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}



@end
