//
//  JCPlaneNode.m
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/16.
//

#import "JCPlaneNode.h"
#import <ARKit/ARKit.h>

@interface JCPlaneNode ()

@property (nonatomic, strong) ARPlaneAnchor         *anchor; // 记录锚点
@property (nonatomic, strong) SCNPlane              *planeGeometry; // 平面模型

@property (nonatomic, strong) SCNNode               *chileNode;

@end

@implementation JCPlaneNode

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor {
    if (self = [super init]) {
        // 创建几何图形
        [self createPlaneGeometry];
        // 更新大小 、 坐标
        [self updatePlaneWithAnchor:anchor];
    }
    return self;
}

- (void)createPlaneGeometry {
    self.planeGeometry = [SCNPlane planeWithWidth:0.01 height:0.01];
    
    // 材质
    SCNMaterial *material = [[SCNMaterial alloc] init];
    UIImage *image = [UIImage imageNamed:@"tron_grid"];
    material.diffuse.contents = image;
    material.lightingModelName = SCNLightingModelPhysicallyBased;
    self.planeGeometry.materials = @[material];
    
    SCNNode *planeNode = [SCNNode nodeWithGeometry:self.planeGeometry];
    planeNode.position = SCNVector3Make(0, 0, 0);
    planeNode.transform = SCNMatrix4MakeRotation(-M_PI_2, 1.0, 0.0, 0.0);
    [self addChildNode:planeNode];
    
    self.chileNode = planeNode;
}

- (void)updatePlaneWithAnchor:(ARPlaneAnchor *)anchor {
    self.anchor = anchor;
    
    self.planeGeometry.width = anchor.extent.x;
    self.planeGeometry.height = anchor.extent.z;
    
    self.chileNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
    
    [self setTextureScale];
}

- (void)setTextureScale {
    CGFloat width = self.planeGeometry.width;
    CGFloat height = self.planeGeometry.height;
    
    SCNMaterial *matrial = self.planeGeometry.materials.firstObject;
    matrial.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1);
    matrial.diffuse.wrapS = SCNWrapModeRepeat;
    matrial.diffuse.wrapT = SCNWrapModeRepeat;
}

@end
