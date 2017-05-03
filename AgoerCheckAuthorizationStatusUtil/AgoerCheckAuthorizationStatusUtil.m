//
//  AgoerCheckAuthorizationStatus.m
//  AgoerCheckAuthorizationStatus
//
//  Created by 李二狗 on 2017/5/3.
//  Copyright © 2017年 YRHY Science and Technology (Beijing) Co., Ltd. All rights reserved.
//

#import "AgoerCheckAuthorizationStatusUtil.h"
#import <CoreLocation/CoreLocation.h>
#import <EventKit/EventKit.h>


//通讯录
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0

#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>

#elif

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#endif

//相册
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0


#import <Photos/Photos.h>

#elif

#import <AssetsLibrary/AssetsLibrary.h>


#endif


@implementation AgoerCheckAuthorizationStatusUtil

+ (void)CheckAgoerCheckAuthorizationStatusWithType:(AgoerCheckAuthorizationType)type resultBlock:(AgoerCheckAuthorizationStatusBlock)block
{
    
    switch (type) {
        case AgoerCheckAuthorizationTypeAddressBookORContancts:
        {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_9_0
            
                CNContactStore *contactStore = [[CNContactStore alloc] init];
                CNAuthorizationStatus authStatus  =  [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
                if (authStatus != CNAuthorizationStatusAuthorized) {
                    
                    [contactStore requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            if (!granted)
                            {
                                
                                block(type,kAgoerCheckAuthorizationStatusDenied);
                            }
                            else
                            {
                                block(type,kAgoerCheckAuthorizationStatusAuthorized);
                            }
                        });
                    }];
                    
                } else {
                    block(type,kAgoerCheckAuthorizationStatusAuthorized);
                }
            
            
#elif
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
            ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
            if (authStatus != kABAuthorizationStatusAuthorized)
            {
                ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                         {
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 if (!granted)
                                                                 {
                                                                     
                                                                      block(type,kAgoerCheckAuthorizationStatusDenied);
                                                                 }
                                                                 else
                                                                 {
                                                                     block(type,kAgoerCheckAuthorizationStatusAuthorized);
                                                                 }
                                                             });
                                                         });
            } else {
                block(type,kAgoerCheckAuthorizationStatusAuthorized);
            }
            
#endif
            
            
        }
            break;
        case kAgoerCheckAuthorizationTypeCamera:
        {
            
            //相册
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
            
            //请求并获取权限状态
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                switch (status) {
                    case PHAuthorizationStatusNotDetermined:
                        block(type,kAgoerCheckAuthorizationStatusNotDetermined);
                        break;
                    case PHAuthorizationStatusRestricted:
                        block(type,kAgoerCheckAuthorizationStatusRestricted);
                        break;
                    case PHAuthorizationStatusDenied:
                        block(type,kAgoerCheckAuthorizationStatusDenied);
                        break;
                    case PHAuthorizationStatusAuthorized:
                        block(type,kAgoerCheckAuthorizationStatusAuthorized);
                        break;
                }
            }];
            
            

            
#elif
            
          //仅仅是权限的check，并不能请求权限
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
            switch (author) {
                case ALAuthorizationStatusNotDetermined:
                    block(type,kAgoerCheckAuthorizationStatusNotDetermined);
                    break;
                case ALAuthorizationStatusRestricted:
                 block(type,kAgoerCheckAuthorizationStatusRestricted);
                    break;
                case ALAuthorizationStatusDenied:
                     block(type,kAgoerCheckAuthorizationStatusDenied);
                    break;
                case ALAuthorizationStatusAuthorized:
                     block(type,kAgoerCheckAuthorizationStatusAuthorized);
                    break;
            }

#endif

        }
            break;
        case kAgoerCheckAuthorizationTypePhotos:
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {//相机权限
                if (!granted) {
                    block(type,kAgoerCheckAuthorizationStatusDenied);
                }else{
                     block(type,kAgoerCheckAuthorizationStatusAuthorized);
                }
            }];
        }
             break;
        case kAgoerCheckAuthorizationTypeAVAudioSession:
        {
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {//麦克风权限
                if (!granted) {
                    block(type,kAgoerCheckAuthorizationStatusDenied);
                }else{
                    block(type,kAgoerCheckAuthorizationStatusAuthorized);
                }
            }];
        }
            break;
        case kAgoerCheckAuthorizationTypeLocationInUse:
        {
            CLLocationManager *manager = [[CLLocationManager alloc] init];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            [manager requestWhenInUseAuthorization];//使用的时候获取定位信息
#elif
            [manager startUpdatingLocation];
#endif
            
            
            BOOL isLocation = [CLLocationManager locationServicesEnabled];
            if (!isLocation) {
                block(type,kAgoerCheckAuthorizationStatusDenied);
            }
            CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
            switch (CLstatus) {
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
                    
                case kCLAuthorizationStatusAuthorizedAlways:
                    block(type,kAgoerCheckAuthorizationStatusAuthorizedAlways);
                    break;
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                    block(type,kAgoerCheckAuthorizationStatusAuthorizedInUse);
                    break;
#elif
                case kCLAuthorizationStatusAuthorized:
                    [manager stopUpdatingLocation];
                    block(type,kAgoerCheckAuthorizationStatusAuthorized);
                    break;
                    
#endif
                case kCLAuthorizationStatusDenied:
                    block(type,kAgoerCheckAuthorizationStatusDenied);
                    break;
                case kCLAuthorizationStatusNotDetermined:
                    block(type,kAgoerCheckAuthorizationStatusNotDetermined);
                    break;
                case kCLAuthorizationStatusRestricted:
                     block(type,kAgoerCheckAuthorizationStatusRestricted);
                    break;
                default:
                    break;
            }
            
        }
            break;
        case kAgoerCheckAuthorizationTypeLocationAlways:
        {
            CLLocationManager *manager = [[CLLocationManager alloc] init];
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
        [manager requestAlwaysAuthorization];//一直获取定位信息
#elif
    
            
#endif
           
            
            BOOL isLocation = [CLLocationManager locationServicesEnabled];
            if (!isLocation) {
                block(type,kAgoerCheckAuthorizationStatusDenied);
            }
            CLAuthorizationStatus CLstatus = [CLLocationManager authorizationStatus];
            switch (CLstatus) {
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0

                case kCLAuthorizationStatusAuthorizedAlways:
                    block(type,kAgoerCheckAuthorizationStatusAuthorizedAlways);
                    break;
                case kCLAuthorizationStatusAuthorizedWhenInUse:
                    block(type,kAgoerCheckAuthorizationStatusAuthorizedInUse);
                    break;
#elif
                case kCLAuthorizationStatusAuthorized:
                    [manager stopUpdatingLocation];
                    block(type,kAgoerCheckAuthorizationStatusAuthorized);
                    break;

#endif
                         
                case kCLAuthorizationStatusDenied:
                    block(type,kAgoerCheckAuthorizationStatusDenied);
                    break;
                case kCLAuthorizationStatusNotDetermined:
                    block(type,kAgoerCheckAuthorizationStatusNotDetermined);
                    break;
                case kCLAuthorizationStatusRestricted:
                    block(type,kAgoerCheckAuthorizationStatusRestricted);
                    break;
                default:
                    break;
            }
            
        }
            break;
        case kAgoerCheckAuthorizationTypeBluetooth:
        {
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    NSLog(@"Authorized");
                }else{
                    NSLog(@"Denied or Restricted");
                }
            }];
        }
            break;
        case kAgoerCheckAuthorizationTypeEKEventStore:
        {
            EKEventStore *store = [[EKEventStore alloc]init];
            [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
                if (granted) {
                    NSLog(@"Authorized");
                }else{
                    NSLog(@"Denied or Restricted");
                }
            }];
        }
            break;
       
    }
    
}

@end
