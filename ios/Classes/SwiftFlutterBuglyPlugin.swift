import Flutter
import UIKit
import Bugly

public class SwiftFlutterBuglyPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_bugly", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterBuglyPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult){
        if call.method == "initCrashReport" {//初始化
            let dict = call.arguments as? Dictionary<String,Any>
            var appId:String = ""
            if let dict = dict {
                appId = dict["appId"] as? String ?? ""
            }

            Bugly.start(withAppId: appId)
            result(0)

        } else if call.method == "postException" {//异常推送
            let dict = call.arguments as? Dictionary<String,Any>
            var reason:String = ""
            var stacks:Array<Any> = []
            if let dict = dict {
                reason = dict["error"] as? String ?? ""
                if let stackTrace = dict["stackTrace"] {
                    stacks.append(stackTrace)
                }
            }

            Bugly.reportException(withCategory: 4, name: "Flutter Exception", reason: reason, callStack: stacks, extraInfo: [:], terminateApp: false)
            result(0)

        } else if call.method == "setUserId" {//设置用户id
            let dict = call.arguments as? Dictionary<String,Any>
            var userId:String = ""
            if let dict = dict {
                userId = dict["userId"] as? String ?? ""
            }

            Bugly.setUserIdentifier(userId)
            result(0)

        } else if call.method == "putUserData" {//自定义信息
            let dict = call.arguments as? Dictionary<String,Any>
            var value:String = ""
            var key:String = ""

            if let dict = dict {
                key = dict["key"] as? String ?? ""
                value = dict["value"] as? String ?? ""
            }

            Bugly.setUserValue(value, forKey: key)
            result(0)

        }
        
        //测试
        if call.method == "testIOSCrash" {

            let _testArray:[String] = ["A","B","C"]

            for index in 0..._testArray.count {
                let _ = _testArray[index] + " Level"
            }
            result(0)

        }
        result("iOS " + UIDevice.current.systemVersion)
    }
}
