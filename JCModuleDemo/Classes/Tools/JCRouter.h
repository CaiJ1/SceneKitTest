//
//  JCRouter.h
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 处理调用完过程回调， 可传任意oc对象
typedef void(^JCRouterCompletionBlock)(id __nullable object);

/*
 输出方demo:
 JCRouter_Extern_Methon(JDProductModule, showProduct, arg, callback) {
 
    // do something
    return @"abc";
 }
 */
// 组件对外公开接口, m组件名, i接口名, p(arg)接收参数, c(callback)回调block
#define JCRouter_Extern_Methon(m, i, p, c) + (id)routerHandle_##m##_##i:(NSDictionary *)arg callback:(JCRouterCompletionBlock)callback



/// 路由控制器
/// 组件业务A与业务B之间不能有相互引用， 不可以直接调用
@interface JCRouter : NSObject

/// 组件通信（输入方）
/// @param urlString Scheme的url， 入 router://JCViewController/userInfo?uid=123, 通过url query传入的参数获取为字典类型
/// @param arg 为任意oc对象， nil。 注意：如果arg为字典类型，拼装结果要由于query中相同字段（query中相同字段会被替换）， 不为字典时，query有参数时以key为 *** 获取
/// @param error 通信过程异常
/// @param completion 通信完后相应的callback， 业务输出方自行维护该block
+ (nullable id)openURL:(nonnull NSString *)urlString arg:(nullable id)arg error:( NSError*__nullable *__nullable)error completion:(nullable JCRouterCompletionBlock)completion;

@end

NS_ASSUME_NONNULL_END
