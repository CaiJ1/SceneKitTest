//
//  JCPlaneNode.h
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/16.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JCPlaneNode : SCNNode

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor;

- (void)updatePlaneWithAnchor:(ARPlaneAnchor *)anchor;

@end

NS_ASSUME_NONNULL_END
