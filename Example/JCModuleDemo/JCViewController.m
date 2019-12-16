//
//  JCViewController.m
//  JCModuleDemo
//
//  Created by jiacai on 12/13/2019.
//  Copyright (c) 2019 jiacai. All rights reserved.
//

#import "JCViewController.h"
#import "JCRouter.h"

@interface JCViewController ()

@property (nonatomic, strong) UIButton          *routerButton;

@end

@implementation JCViewController
#pragma mark - init dealloc
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initSubViews];
}


#pragma mark - private function
- (void)initSubViews {
    [self.view addSubview:self.routerButton];
    self.routerButton.frame = CGRectMake(100, 100, 200, 100);
//    self.routerButton 
}

#pragma mark - public function

#pragma mark - action function
- (void)routerButtonOnClicked {
//    JCRouter *r = [[JCRouter alloc] init];
    
    NSString *url = @"openApp.JCModule://JCARKitViewController/exportInterface?mod=forumdisplay&fid=153";
    [JCRouter openURL:url arg:nil error:nil completion:nil];
}

#pragma mark - getter setter
- (UIButton *)routerButton {
    if (!_routerButton) {
        _routerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_routerButton setTitle:@"router" forState:UIControlStateNormal];
        [_routerButton addTarget:self action:@selector(routerButtonOnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _routerButton;
}

#pragma mark - delegate

@end
