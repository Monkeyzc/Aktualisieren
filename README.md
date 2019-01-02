Aktualisieren

根据从Apple Store获取当前App版本信息, 提示用户更新app

# Usage

## Objective-C
1. 导入`Aktualisieren.h, Aktualisieren.m`两个文件到工程
2. 在`application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中加入`[Aktualisieren checkNewVersionWithAppId: #YourAppId#];`

## Swift
1. 导入`Aktualisieren.swift`文件到工程
2. 在`func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)`中加入:`Aktualisieren.checkNewVersion(withAppId: #YourAppId#)`