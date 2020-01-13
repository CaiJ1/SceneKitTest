//
//  JCViewController.m
//  JCModuleDemo
//
//  Created by jiacai on 12/13/2019.
//  Copyright (c) 2019 jiacai. All rights reserved.
//

#import "JCViewController.h"
#import "JCRouter.h"
#import "JCUtils.h"
#import <Masonry/Masonry.h>

static NSString * const cellIdentifier = @"modelCellIdentifier";

struct JCModuleModel {
    const char *showName; // 展示名称
    const char *className; // 类名
    const char *interfaceName; // 接口名
    BOOL            valid; // model 是否有效
};
typedef struct JCModuleModel JCModuleModel;

static inline JCModuleModel JCModuleModelMake(const char *showName, const char *class, const char *interface) {
    JCModuleModel model;
    model.showName = showName;
    model.className = class;
    model.interfaceName = interface;
    model.valid = YES;
    return model;
}

@interface JCViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton          *routerButton;
@property (nonatomic, strong) UIButton          *backButton;

@property (nonatomic, strong) UITableView       *tableView; //列表
@property (nonatomic, strong) NSMutableArray    *dataArray; // 数据

@end

@implementation JCViewController
#pragma mark - init dealloc
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
    [self initSubViews];
    
    [self.tableView reloadData];
}


#pragma mark - private function
- (void)initSubViews {
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [win addSubview:self.routerButton];
    [self.routerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(100);
    }];
    [win addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.top.mas_equalTo(self.routerButton.mas_bottom);
        make.centerX.mas_equalTo(self.routerButton);
    }];
}

- (void)initData {
    JCModuleModel arModel = JCModuleModelMake("ARKit官方Demo-改",
                                              "JCARKitViewController",
                                              "getJCARKitViewController");
    [self addModuleDataToArray:arModel];
    
    JCModuleModel diceModel = JCModuleModelMake("色子游戏",
                                              "PlayDicesViewController",
                                              "getPlayDicesViewController");
    [self addModuleDataToArray:diceModel];

}
- (void)addModuleDataToArray:(JCModuleModel)model {
    NSValue *value = [NSValue valueWithBytes:&model objCType:@encode(JCModuleModel)];
    [self.dataArray addObject:value];
}
- (JCModuleModel)getModuleFromArray:(NSInteger)index {
    JCModuleModel model;
    model.valid = NO;
    if (index < self.dataArray.count) {
        NSValue *value = self.dataArray[index];
        [value getValue:&model];
        return model;
    }
    return model;
}
- (void)removeModuleDataFromArray:(JCModuleModel)model {
    NSValue *value = [NSValue valueWithBytes:&model objCType:@encode(JCModuleModel)];
    if ([self.dataArray containsObject:value]) {
        [self.dataArray removeObject:value];
    }
}
- (NSString *)dealModuleDataToURL:(JCModuleModel)model {
    NSString *url = @"openApp.JCModule://";
    url = [url stringByAppendingFormat:@"%s/%s?%@", model.className, model.interfaceName, @"JC"];
    return url;
}

- (void)jumpToControllerWithModule:(JCModuleModel)model {
    if (model.valid) {
        NSString *url = [self dealModuleDataToURL:model];
        UIViewController *controller = [JCRouter openURL:url arg:nil error:nil completion:nil];
        
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        NSLog(@" JC ------> jump 无效数据");
    }
}

#pragma mark - public function

#pragma mark - action function
- (void)routerButtonOnClicked {
//    JCRouter *r = [[JCRouter alloc] init];
    JCModuleModel defaultModel = [self getModuleFromArray:0];
    [self jumpToControllerWithModule:defaultModel];
}

- (void)backButtonOnClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableViewDidClickedOnIndex:(NSInteger)index {
    JCModuleModel defaultModel = [self getModuleFromArray:index];
    [self jumpToControllerWithModule:defaultModel];
}

#pragma mark - getter setter
- (UIButton *)routerButton {
    if (!_routerButton) {
        _routerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_routerButton setTitle:@"调试" forState:UIControlStateNormal];
        [_routerButton addTarget:self action:@selector(routerButtonOnClicked) forControlEvents:UIControlEventTouchUpInside];
        _routerButton.backgroundColor = UIColor.purpleColor;
        _routerButton.layer.borderWidth = 0.1;
        _routerButton.layer.cornerRadius = 25;
        _routerButton.layer.masksToBounds = YES;
    }
    return _routerButton;
}
- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setTitle:@"🔙" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonOnClicked) forControlEvents:UIControlEventTouchUpInside];
        _backButton.backgroundColor = UIColor.grayColor;
        _backButton.layer.borderWidth = 0.1;
        _backButton.layer.cornerRadius = 25;
        _backButton.layer.masksToBounds = YES;
    }
    return _backButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    }
    return _tableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

#pragma mark - delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    JCModuleModel model = [self getModuleFromArray:indexPath.row];
    cell.textLabel.text = [NSString stringWithUTF8String:model.showName];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.dataArray.count) {
        return;
    }
    
    [self tableViewDidClickedOnIndex:indexPath.row];
}

@end

