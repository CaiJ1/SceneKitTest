//
//  JCRouter.m
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/13.
//

#import "JCRouter.h"
#import <objc/runtime.h>

@implementation JCRouter

#pragma mark - 数据处理
+ (id)openURL:(NSString *)urlString arg:(id)arg error:(NSError * _Nullable __autoreleasing *)error completion:(JCRouterCompletionBlock)completion {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:urlString];
    NSLog(@" JC ------> %@", components);
    
    NSDictionary *argument = [JCRouter queryUrlDataQueryItems:components.queryItems andArg:arg];
    NSLog(@" JC ------> allArgument:%@", argument);
    
    return [JCRouter jumpWithUrlData:components andArg:argument callback:completion];
}

+ (NSDictionary *)queryUrlDataQueryItems:(NSArray<NSURLQueryItem *> *)queryItems andArg:(id)arg {

    NSMutableDictionary *arguments = [NSMutableDictionary dictionaryWithCapacity:queryItems.count];
    for (NSURLQueryItem *item in queryItems) {
        [arguments setValue:item.value forKey:item.name];
    }
    
    // 字典类型， 优先使用arg的数据（覆盖）
    if ([arg isKindOfClass:[NSDictionary class]]) {
        NSDictionary *argDic = ((NSDictionary*)arg);
        for (NSString *key in argDic.allKeys) {
            [arguments setValue:argDic[key] forKey:key];
        }
    }
    return arguments;
}

#pragma mark - 业务处理
+ (id)jumpWithUrlData:(NSURLComponents *)components andArg:(NSDictionary *)arg callback:(JCRouterCompletionBlock)callBack {
    NSString *funcString = [JCRouter getModuleInterfaceWithUrlData:components];
    Class classModule = NSClassFromString(components.host);
    SEL selector = NSSelectorFromString(funcString);
    
    JCRouterCompletionBlock b = ^(id jc){

    };
    
    id result = nil;
//    [JCRouter invocationMethod:selector andParam:@[arg, b] andClass:classModule andTarget:nil andReturnLoct:&result];
    result = [JCRouter impMethod:selector andParam:@[arg, b] andClass:classModule andTarget:nil andReturnLoct:nil];
    return result;
}

+ (void)openURLScheme:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    // 打开url
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - 动态方法调用
// + (id)routerHandle_##m##_##i:(NSDictionary *)arg callback:(JCRouterCompletionBlock)callback
+ (NSString *)getModuleInterfaceWithUrlData:(NSURLComponents *)components {
    NSString *path = [components.path substringFromIndex:1];// 第一个值为/, 删除
    NSString *functionString = [NSString stringWithFormat:@"routerHandle_%@_%@:callback:", components.host, path];
    return functionString;
}
+ (id)impMethod:(SEL)aSelector andParam:(NSArray *)objects andClass:(Class)mClass andTarget:(id)target andReturnLoct:(void *)returnLoct {
    IMP methonIMP = [mClass methodForSelector:aSelector];
    id(*function)(id, SEL, NSDictionary *, JCRouterCompletionBlock) = (void *)methonIMP;
    id result = function(mClass, aSelector, objects.firstObject, objects[1]);
    return result;
}
+ (void)invocationMethod:(SEL)aSelector andParam:(NSArray *)objects andClass:(Class)mClass andTarget:(id)target andReturnLoct:(void *)returnLoct {
    NSMethodSignature *methodSignature = nil;
    if (target) {
        methodSignature = [mClass instanceMethodSignatureForSelector:aSelector];
    } else {
        methodSignature = [[mClass class] methodSignatureForSelector:aSelector];
    }
    
    if(methodSignature == nil)
    {
        @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        return;
    }
    else
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:target?:mClass]; // 有target，使用target（实例方法）；否则使用class（类方法）
        [invocation setSelector:aSelector];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第3个开始
        NSInteger  signatureParamCount = methodSignature.numberOfArguments - 2;
        NSInteger requireParamCount = objects.count;
        NSInteger resultParamCount = MIN(signatureParamCount, requireParamCount);
        for (NSInteger i = 0; i < resultParamCount; i++) {
            id  obj = objects[i];
            const char *argumentType = [methodSignature getArgumentTypeAtIndex:i+2];
            if ([obj isKindOfClass:NSNull.class]) {
                // 空值直接跳过
                continue;
            }
            switch (argumentType[0]=='r'?argumentType[1]:argumentType[0]) {
#define VK_CALL_ARG_CASE(_typeString, _type, _selector) \
case _typeString: {                              \
_type value = [obj _selector];                     \
[invocation setArgument:&value atIndex:i+2];\
break; \
}
                    VK_CALL_ARG_CASE('c', char, charValue)
                    VK_CALL_ARG_CASE('C', unsigned char, unsignedCharValue)
                    VK_CALL_ARG_CASE('s', short, shortValue)
                    VK_CALL_ARG_CASE('S', unsigned short, unsignedShortValue)
                    VK_CALL_ARG_CASE('i', int, intValue)
                    VK_CALL_ARG_CASE('I', unsigned int, unsignedIntValue)
                    VK_CALL_ARG_CASE('l', long, longValue)
                    VK_CALL_ARG_CASE('L', unsigned long, unsignedLongValue)
                    VK_CALL_ARG_CASE('q', long long, longLongValue)
                    VK_CALL_ARG_CASE('Q', unsigned long long, unsignedLongLongValue)
                    VK_CALL_ARG_CASE('f', float, floatValue)
                    VK_CALL_ARG_CASE('d', double, doubleValue)
                    VK_CALL_ARG_CASE('B', BOOL, boolValue)
                    
                default: {
                    [invocation setArgument:&obj atIndex:i+2];
                }
            }
        }
        [invocation invoke];
        
        //返回值处理
        if(methodSignature.methodReturnLength > 0 && returnLoct != NULL) {
            [invocation getReturnValue:returnLoct];
        }
    }
}

@end
