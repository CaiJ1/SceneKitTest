//
//  JCUtils.h
//  JCModuleDemo
//
//  Created by 贾才 on 2019/12/31.
//

#import <Foundation/Foundation.h>


typedef struct _JCUtils_t {
    float (*cpu_usage)(void);
    float (*cpu_usage2)(void);
    
} JCUtils_s;

// 常用工具包， 设备信息、时间、MD5、Base64、Color、内存信息等
extern JCUtils_s JCUtils;
