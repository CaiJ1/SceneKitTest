//
//  PlayDicesViewController.m
//  JCModuleDemo
//
//  Created by 贾才 on 2020/1/3.
//

#import "PlayDicesViewController.h"
#import "JCRouter.h"
#import <Masonry/Masonry.h>
#import <ARKit/ARKit.h>

typedef enum : NSUInteger {
    GameStateDetectSurface,
    GameStatePointToSurface,
    GameStateSwipeToPlay,
} GameState;


@interface PlayDicesViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) ARSCNView         *sceneView;
@property (nonatomic, strong) UILabel           *statusLabel;
@property (nonatomic, strong) UIButton          *startButton;
@property (nonatomic, strong) UIButton          *styleButton;
@property (nonatomic, strong) UIButton          *resetButton;

@property (nonatomic, assign) GameState         gameState;
@property (nonatomic, copy) NSString            *trackingStatus;
@property (nonatomic, copy) NSString            *statusMessage;

@property (nonatomic, assign) CGPoint           focusPoint;
@property (nonatomic, strong) SCNNode           *focusNode;
@property (nonatomic, strong) SCNNode           *diceNode;
@property (nonatomic, strong) NSMutableArray    *dicesNodes;
@property (nonatomic, strong) SCNNode           *lightNode;
@property (nonatomic, assign) NSInteger         diceCount;
@property (nonatomic, assign) NSInteger         diceStyle;
@property (nonatomic, copy) NSArray           *diceOffset;

@end

@implementation PlayDicesViewController

JCRouter_Extern_Methon(PlayDicesViewController, getPlayDicesViewController, arg, callback) {
    NSLog(@" JC ------> PlayDice 调用成功");
    PlayDicesViewController *controller = [[PlayDicesViewController alloc] init];
    return controller;
}

#pragma mark - init dealloc
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self initSceneView];
    [self initARSession];
    [self initGesture];
    
    [self loadDiceModels];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    
}

#pragma mark - private function
- (void)initData {
    self.diceCount = 3;
    self.diceStyle = 0;
    self.diceOffset = @[[NSValue valueWithSCNVector3:SCNVector3Make(0.0,0.0,0.0)],
                        [NSValue valueWithSCNVector3:SCNVector3Make(-0.05, 0.00, 0.0)],
                        [NSValue valueWithSCNVector3:SCNVector3Make(0.05, 0.00, 0.0)],
                        [NSValue valueWithSCNVector3:SCNVector3Make(-0.05, 0.05, 0.02)],
                        [NSValue valueWithSCNVector3:SCNVector3Make(0.05, 0.05, 0.02)]];
    
}

- (void)initSceneView {
    self.focusPoint = CGPointMake(self.view.center.x, self.view.center.y * 1.25);
    
    SCNScene *scene = [[SCNScene alloc] init];
    scene.paused = NO;
    self.sceneView.scene = scene;
    self.sceneView.frame = self.view.bounds;
    [self.view addSubview:self.sceneView];
    
    scene.lightingEnvironment.contents = @"ARResource.scnassets/Textures/Environment_cube.jpg";
    scene.lightingEnvironment.intensity = 2;
    scene.physicsWorld.speed = 1;
    scene.physicsWorld.timeStep = 1.0/60.0;
}

- (void)initARSession {
    if (!ARWorldTrackingConfiguration.isSupported) {
        return;
    }
    
    [self startSession];
}

- (void)initGesture {
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(sceneViewDidSwipeUp:)];
    swip.direction = UISwipeGestureRecognizerDirectionUp;
    [self.sceneView addGestureRecognizer:swip];
}

- (void)loadDiceModels {
    SCNScene *diceScene = [SCNScene sceneNamed:@"ARResource.scnassets/DiceScene.scn"];
    for (int i = 0; i < 5; i++) {
        SCNNode *nodel = [diceScene.rootNode childNodeWithName:[NSString stringWithFormat:@"Dice%d", i] recursively:NO];
        [self.dicesNodes addObject:nodel];
    }
    
    SCNScene *focusScene = [SCNScene sceneNamed:@"ARResource.scnassets/Models/Dice.dae"];
    self.focusNode = [focusScene.rootNode childNodeWithName:@"Dice" recursively:NO];
    [self.sceneView.scene.rootNode addChildNode:self.focusNode];
    
    self.lightNode = [diceScene.rootNode childNodeWithName:@"directional" recursively:NO];
    [self.sceneView.scene.rootNode addChildNode:self.lightNode];
}

- (void)throwDiceNode:(SCNMatrix4)transform andOffset:(SCNVector3)offset {
    CGFloat distance = simd_distance(self.focusNode.simdPosition, simd_make_float3(transform.m41, transform.m42, transform.m43));
    SCNVector3 direction = SCNVector3Make(-(distance * 2.5) * transform.m31, -(distance * 2.5)* (transform.m32 - M_PI_4), -(distance * 2.5) * transform.m33);
    SCNVector3 rotation = SCNVector3Make(arc4random()%100 / 100.f, arc4random()%100 / 100.f, arc4random()%100 / 100.f);
    SCNVector3 position = SCNVector3Make(transform.m41 + offset.x, transform.m42 + offset.y, transform.m43 + offset.z);
    SCNNode *diceNode = [self.dicesNodes[self.diceStyle] clone];
    
    diceNode.name = @"dice";
    diceNode.position = position;
    diceNode.eulerAngles = rotation;
    [diceNode.physicsBody resetTransform];
    [diceNode.physicsBody applyForce:direction impulse:YES];
    [self.sceneView.scene.rootNode addChildNode:diceNode];
    
    self.diceCount--;
}

- (void)updateStatus {
    switch (self.gameState) {
        case GameStateDetectSurface:
            NSLog(@" JC ------> %@", @"Scan entire table surface...\nHit START when ready!");
            break;
        case GameStatePointToSurface:
//            NSLog(@" JC ------> %@", @"Point at designated surface first!");
            break;
        case GameStateSwipeToPlay:
            NSLog(@" JC ------> %@", @"Swipe UP to throw!\nTap on dice to collect it again.");
            break;
    }
}

- (void)updateFocusNode {
    NSArray<ARHitTestResult*> *results = [self.sceneView hitTest:self.focusPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
    
    if (results.count > 0) {
        ARHitTestResult *re = results.firstObject;
        simd_float4x4 t = re.worldTransform;
        self.focusNode.position = SCNVector3Make(t.columns[3].x, t.columns[3].y, t.columns[3].z);
        self.gameState = GameStateSwipeToPlay;
    } else {
        self.gameState = GameStatePointToSurface;
    }
}

- (SCNNode *)createARPlaneNode:(ARPlaneAnchor *)planeAnchor andColor:(UIColor *)color {
    SCNPlane *plane = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
    
    SCNMaterial *material = [SCNMaterial material];
    material.diffuse.contents = color;// @"ARResource.scnassets/Textures/Surface_diffuse.png"; // color;
    plane.materials = @[material];
    
    SCNNode *pNode = [SCNNode nodeWithGeometry:plane];
    pNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
    pNode.transform = SCNMatrix4MakeRotation(-M_PI / 2.f, 1, 0, 0);
    
    pNode.physicsBody = [self createARPlanePhysics:plane];
    return pNode;
}
- (void)updateARPlaneNode:(SCNNode *)pNode andPlaneAchor:(ARPlaneAnchor *)planeAchor {
    SCNPlane *plane = (SCNPlane *)pNode.geometry;
    plane.width = planeAchor.extent.x;
    plane.height = planeAchor.extent.z;

    pNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z);
    pNode.physicsBody = nil;
    pNode.physicsBody = [self createARPlanePhysics:plane];
}
- (void)removeARPlaneNode:(SCNNode *)pNode {
    for (SCNNode *child in pNode.childNodes) {
        [child removeFromParentNode];
    }
}
- (SCNPhysicsBody *)createARPlanePhysics:(SCNPlane *)plane {
    SCNPhysicsBody *physics = [SCNPhysicsBody bodyWithType:SCNPhysicsBodyTypeKinematic shape:[SCNPhysicsShape shapeWithGeometry:plane options:nil]];
    physics.restitution = 0.5;
    physics.friction = 0.5;
    return physics;
}

- (void)updateDiceNodes {
    for (SCNNode *node in self.sceneView.scene.rootNode.childNodes) {
        if ([node.name isEqualToString:@"dice"]) {
            if (node.presentationNode.position.y < -2) {
                [node removeFromParentNode];
                self.diceCount++;
            }
        }
    }
}


#pragma mark - public function
- (void)suspendARPlaneDetection {
    ARWorldTrackingConfiguration *config = (ARWorldTrackingConfiguration *)self.sceneView.session.configuration;
    config.planeDetection = ARPlaneDetectionNone;
    [self.sceneView.session runWithConfiguration:config];
}

- (void)hideARPlaneNodes {
    for (ARAnchor *anchor in self.sceneView.session.currentFrame.anchors) {
        SCNNode *node = [self.sceneView nodeForAnchor:anchor];
        for (SCNNode *child in node.childNodes) {
            SCNMaterial *material = child.geometry.materials.firstObject;
            material.colorBufferWriteMask = SCNColorMaskNone;
        }
    }
}

- (void)startSession {
    ARWorldTrackingConfiguration *config = [[ARWorldTrackingConfiguration alloc] init];
    config.worldAlignment = ARWorldAlignmentGravity;
    config.providesAudioData = NO;
    config.planeDetection = ARPlaneDetectionHorizontal;
    config.lightEstimationEnabled = YES;
    [self.sceneView.session runWithConfiguration:config];
}
- (void)resetARSession {
    [self startSession];
}
- (void)startGame {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self suspendARPlaneDetection];
        
        [self hideARPlaneNodes];
        self.gameState = GameStatePointToSurface;
    });
}
- (void)resetGame {
    dispatch_async(dispatch_get_main_queue(), ^{
       [self resetARSession];
        self.gameState = GameStateDetectSurface;
    });
}

#pragma mark - action function
- (void)startButtonOnClicked {
    
}
- (void)styleButtonOnClicked {
    
}
- (void)resetButtonOnClicked {
    
}
- (void)swipeUpGestureHandler:(UISwipeGestureRecognizer *)gesture {
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    dispatch_async(dispatch_get_main_queue(), ^{
        UITouch *touch = touches.anyObject;
        CGPoint location = [touch locationInView:self.sceneView];
         
        SCNHitTestResult *hit = [self.sceneView hitTest:location options:nil].firstObject;
        if ([hit.node.name isEqualToString:@"dice"]) {
            [hit.node removeFromParentNode];
            self.diceCount++;
        }
    });
}
- (void)sceneViewDidSwipeUp:(UISwipeGestureRecognizer *)swip {
    if (self.gameState != GameStateSwipeToPlay) {
        return;
    }
    ARFrame *frame = self.sceneView.session.currentFrame;
    if (!frame) {
        return;
    }
    
    for (int i = 0; i < self.diceCount; i++) {
        [self throwDiceNode:SCNMatrix4FromMat4(frame.camera.transform) andOffset:[self.diceOffset[i] SCNVector3Value]];
    }
    
}

#pragma mark - getter setter
- (ARSCNView *)sceneView {
    if (!_sceneView) {
        _sceneView = [[ARSCNView alloc] init];
        _sceneView.backgroundColor = UIColor.whiteColor;
        _sceneView.delegate = self;
//        _sceneView.debugOptions = SCNDebugOptionShowWireframe | SCNDebugOptionShowBoundingBoxes | ARSCNDebugOptionShowFeaturePoints;
    }
    return _sceneView;
}

- (NSMutableArray *)dicesNodes {
    if (!_dicesNodes) {
        _dicesNodes = [NSMutableArray array];
    }
    return _dicesNodes;
}

#pragma mark - delegate
#pragma mark ARSCNViewDelegate
- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateStatus];
        [self updateFocusNode];
        [self updateDiceNodes];
//    });
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            SCNNode *pNode = [self createARPlaneNode:(ARPlaneAnchor *)anchor andColor:UIColor.yellowColor];
            [node addChildNode:pNode];
//        });
    }
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateARPlaneNode:node.childNodes.firstObject andPlaneAchor:(ARPlaneAnchor *)anchor];
//        });
    }
}
- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeARPlaneNode:node];
//        });
    }
}



@end
