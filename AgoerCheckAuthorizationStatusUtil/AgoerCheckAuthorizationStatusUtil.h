//
//  AgoerCheckAuthorizationStatus.h
//  AgoerCheckAuthorizationStatus
//
//  Created by 李二狗 on 2017/5/3.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef CF_ENUM(CFIndex, AgoerCheckAuthorizationStatus)
{
    kAgoerCheckAuthorizationStatusNotDetermined,  //未询问用户
    kAgoerCheckAuthorizationStatusRestricted,     //受限制的
    kAgoerCheckAuthorizationStatusDenied,         //用户已拒绝
    kAgoerCheckAuthorizationStatusAuthorized,     //用户已授权
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
    kAgoerCheckAuthorizationStatusAuthorizedInUse, //用户已授权  //如果是定位，那么此类型为使用时定位
    kAgoerCheckAuthorizationStatusAuthorizedAlways, //用户已授权  //如果是定位，那么此类型为持续定位

#endif
   
};


typedef CF_ENUM(CFIndex, AgoerCheckAuthorizationType)
{
    AgoerCheckAuthorizationTypeAddressBookORContancts,  //通讯录
    kAgoerCheckAuthorizationTypeLocationInUse,     //使用时定位
    kAgoerCheckAuthorizationTypeLocationAlways,     //持续定位
    kAgoerCheckAuthorizationTypePhotos,         //相册
    kAgoerCheckAuthorizationTypeCamera,     //相机
    kAgoerCheckAuthorizationTypeBluetooth,  //蓝牙
    kAgoerCheckAuthorizationTypeAVAudioSession, //麦克风
    kAgoerCheckAuthorizationTypeEKEventStore   //日历
};




typedef void(^AgoerCheckAuthorizationStatusBlock)(AgoerCheckAuthorizationType type,AgoerCheckAuthorizationStatus status);


@interface AgoerCheckAuthorizationStatusUtil : NSObject


+ (void)CheckAgoerCheckAuthorizationStatusWithType:(AgoerCheckAuthorizationType)type resultBlock:(AgoerCheckAuthorizationStatusBlock)block;



@end
