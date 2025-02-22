//
//  AppDelegate.m
//  RTMPiOSDemo
//
//  Created by kuenzhang on 16/3/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>

#ifdef ENABLE_TRTC
#ifdef ENABLE_PLAY
#import "TRTCCloud.h"
#import "TXLiveBase.h"  //TRTC
#else
#import "TRTCCloud.h"   //TRTC_Smart
#endif
#else
#import "TXLiveBase.h"  //非TRTC
#endif

#ifndef UGC_SMART
#import "AppLogMgr.h"
#endif
#import "MainViewController.h"
#import "AFNetworkReachabilityManager.h"
#import "Replaykit2Define.h"
#import <UserNotifications/UserNotifications.h>
#import <objc/message.h>

#ifdef ENABLE_UGC
#import "TXUGCBase.h"
#endif

#define BUGLY_APP_ID @"18a2342254"

NSString *helpUrlDb[] = {
    [Help_MLVBLiveRoom] = @"https://cloud.tencent.com/document/product/454/14606",
        [Help_录屏直播 ] = @"https://cloud.tencent.com/document/product/454/7883",
        [Help_超级播放器] = @"https://cloud.tencent.com/document/product/454/18871",
        [Help_视频录制] = @"https://cloud.tencent.com/document/product/584/9367",
        [Help_特效编辑] = @"https://cloud.tencent.com/document/product/584/9375",
        [Help_视频拼接] = @"https://cloud.tencent.com/document/product/584/9370",
        [Help_图片转场] = @"https://cloud.tencent.com/document/product/584/9375#14.-.E5.9B.BE.E7.89.87.E7.BC.96.E8.BE.91",
        [Help_视频上传] = @"https://cloud.tencent.com/document/product/584/15534",
        [Help_双人音视频] = @"https://cloud.tencent.com/document/product/454/14617",
        [Help_多人音视频] = @"https://cloud.tencent.com/document/product/454/14617",
        [Help_rtmp推流] = @"https://cloud.tencent.com/document/product/454/7879",
        [Help_直播播放器] = @"https://cloud.tencent.com/document/product/454/7880",
    [Help_点播播放器] = @"https://cloud.tencent.com/document/product/454/12147",
    [Help_webrtc] = @"https://cloud.tencent.com/document/product/454/16914",
    [Help_TRTC] = @"https://cloud.tencent.com/document/product/647/32221",
    };
    
@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end
//@implementation NSObject (Shit)
//- (void)ac_dealloc {
//
//}
//@end
@implementation AppDelegate

- (void)clickHelp:(UIButton *)sender {
    NSURL *helpUrl = [NSURL URLWithString:helpUrlDb[sender.tag]];
    UIApplication *myApp = [UIApplication sharedApplication];
    if ([myApp canOpenURL:helpUrl]) {
        [myApp openURL:helpUrl];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"remove_cache_preference"]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        [fm removeItemAtPath:[documentPath stringByAppendingPathComponent:@"TXUgcSDK.licence"] error:nil];
        [fm removeItemAtPath:[documentPath stringByAppendingPathComponent:@"TXLiveSDK.licence"] error:nil];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"remove_cache_preference"];
    }
    //启动bugly组件，bugly组件为腾讯提供的用于crash上报和分析的开放组件，如果您不需要该组件，可以自行移除
    BuglyConfig * config = [[BuglyConfig alloc] init];
    NSString *version = nil;
#if ENABLE_TRTC
    version = [TRTCCloud getSDKVersion];
    
#else
    version = [TXLiveBase getSDKVersionStr];
#endif
    
#if DEBUG
    config.debugMode = YES;
#endif
    config.version = version;
    config.channel = @"LiteAV Demo";
    
    [Bugly startWithAppId:BUGLY_APP_ID config:config];
#ifdef ENABLE_UGC
    [TXUGCBase setLicenceURL:@"http://license.vod2.myqcloud.com/license/v1/e0a12d3564e40876abe197297a9fbf8d/TXLiveSDK.licence" key:@"8932c0e28b783976bdee2edcb625a6e1"];
#endif
    
#ifdef ENABLE_PUSH
    [TXLiveBase setLicenceURL:@"http://license.vod2.myqcloud.com/license/v1/e0a12d3564e40876abe197297a9fbf8d/TXLiveSDK.licence" key:@"8932c0e28b783976bdee2edcb625a6e1"];
    
    NSLog(@"TXLiveBaseVersion = %@",[TXLiveBase getSDKVersionStr]);
    
#endif
    
    NSLog(@"rtmp demo init crash report");

    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
#ifdef ENABLE_TRTC
    [TRTCCloud setConsoleEnabled:NO];
    [TRTCCloud setLogLevel:TRTCLogLevelDebug];
    [TRTCCloud setLogDelegate:[AppLogMgr shareInstance]];
#else
    //初始化log模块
#ifndef UGC_SMART
    [TXLiveBase sharedInstance].delegate = [AppLogMgr shareInstance];
    [TXLiveBase setConsoleEnabled:NO];
    [TXLiveBase setAppID:@"1252463788"];
#endif
#endif
    MainViewController* vc = [[MainViewController alloc] init];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, 0)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [[UINavigationBar appearance] setBarTintColor:UIColor.blackColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"transparent.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];

    UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:vc];
    nc.navigationBar.hidden = YES;
    
    self.window.rootViewController = nc;
    
    [self.window makeKeyAndVisible];
#ifndef ENABLE_TRTC
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
#endif
    //For ReplayKit2. 使用 UNUserNotificationCenter 来管理通知
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //监听回调事件
        center.delegate = self;
        
        //iOS 10 使用以下方法注册，才能得到授权
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                              }];
    }

    return YES;
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    
    // 处理完成后条用 completionHandler ，用于指示在前台显示通知的形式
    if (notification.request.content.userInfo.allKeys.count > 0) {
        if ([notification.request.content.userInfo[kReplayKit2UploadingKey] isEqualToString:kReplayKit2Stop]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kCocoaNotificationNameReplayKit2Stop object:nil];
        }
    }
    completionHandler(UNNotificationPresentationOptionSound + UNNotificationPresentationOptionBadge + UNAuthorizationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    if (response.notification.request.content.userInfo.allKeys.count > 0) {
//        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
//        if ([response.notification.request.content.userInfo[kReplayKit2UploadingKey] isEqualToString:kReplayKit2Uploading]) {
//            [defaults setObject:kReplayKit2Uploading forKey:kReplayKit2UploadingKey];
//            [defaults synchronize];
//        }
    }
    completionHandler();
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
