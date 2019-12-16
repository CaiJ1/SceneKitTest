//
//  JCARKitViewController.m
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/13.
//

#import "JCARKitViewController.h"
#import "JCRouter.h"
#import "JCPlaneNode.h"
#import <ARKit/ARKit.h>

@interface JCARKitViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) ARSCNView         *arView; // ar视图
@property (nonatomic, strong) ARSession         *arSession; // ar会话
@property (nonatomic, strong) ARWorldTrackingConfiguration   *arConfig; // 会话配置

@property (nonatomic, strong) NSMutableDictionary   *nodeDic; // 节点存储

@end

@implementation JCARKitViewController

#pragma mark - init dealloc
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
    
    [self setupArViewAndSession];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self startArSession];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    [self stopArSession];
}


#pragma mark - private function
- (void)setupArViewAndSession {
    self.arView.frame = self.view.bounds;
    self.arView.delegate = self;
    [self.view addSubview:self.arView];
    
    self.arSession = self.arView.session;
}

#pragma mark - public function
- (void)startArSession {
    [self.arSession runWithConfiguration:self.arConfig];
}
- (void)stopArSession {
    [self.arSession pause];
}

#pragma mark - action function

#pragma mark - getter setter
- (ARSCNView *)arView {
    if (!_arView) {
        _arView = [[ARSCNView alloc] init];
        _arView.backgroundColor = UIColor.whiteColor;
        
        _arView.showsStatistics = YES;
        _arView.autoenablesDefaultLighting = YES;
        _arView.allowsCameraControl = YES;
        _arView.rendersContinuously = YES;
        _arView.debugOptions = ARSCNDebugOptionShowFeaturePoints | ARSCNDebugOptionShowWorldOrigin;
        
        SCNScene *scene = [[SCNScene alloc] init];
        _arView.scene = scene;
    }
    return _arView;
}
- (ARWorldTrackingConfiguration *)arConfig {
    if (!_arConfig) {
        _arConfig = [[ARWorldTrackingConfiguration alloc] init];
        _arConfig.planeDetection = ARPlaneDetectionHorizontal;
    }
    return _arConfig;
}

- (NSMutableDictionary *)nodeDic {
    if (!_nodeDic) {
        _nodeDic = [NSMutableDictionary dictionary];
    }
    return _nodeDic;
}

#pragma mark - delegate
#pragma mark ARSCNViewDelegate
- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
    JCPlaneNode *jcNode = [[JCPlaneNode alloc] initWithAnchor:planeAnchor];
    [self.nodeDic setValue:jcNode forKey:anchor.identifier.UUIDString];
    
    [node addChildNode:jcNode];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    
    JCPlaneNode *jcNode = self.nodeDic[anchor.identifier.UUIDString];
    if (jcNode) {
        [jcNode updatePlaneWithAnchor:(ARPlaneAnchor *)anchor];
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    [self.nodeDic removeObjectForKey:anchor.identifier];
    
}


@end
