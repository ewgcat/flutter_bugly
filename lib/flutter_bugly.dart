import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:stack_trace/stack_trace.dart';

class FlutterBugly {
  static FlutterBugly? _instance;

  FlutterBugly._();

  static FlutterBugly get instance {
    _instance ??= FlutterBugly._();
    return _instance!;
  }

  static const MethodChannel _channel = MethodChannel('flutter_bugly');

  String? _currentRoute;

  set currentRoute(String value) {
    _currentRoute = value;
  }

  /// 异常转发：
  /// FlutterError.onError = FlutterBugly.instance.recordFlutterError;
  Future<void> recordFlutterError(
      FlutterErrorDetails flutterErrorDetails) async {
    if (null != flutterErrorDetails.stack) {
      // 转发Zone 的错误回调
      Zone.current.handleUncaughtError(
          flutterErrorDetails.exception, flutterErrorDetails.stack!);
    }
  }

  /// 异常记录：try里处理
  Future<void> recordError(dynamic error, StackTrace? stack) async {
    final StackTrace stackTrace = stack ?? StackTrace.current;
    final List<Map<String, String>> stackTraceElements =
        _getStackTraceElements(stackTrace);
    postException(error: error, stackTrace: stackTraceElements.join("\n"));
  }

  /// 初始化
  Future<void> initCrashReport({
    String? appIdAndroid,
    String? appIdIOS,
    debug = false,
    devDevice = false,
  }) async {
    return _channel.invokeMethod("initCrashReport", {
      "appId": Platform.isAndroid ? appIdAndroid : appIdIOS,
      "debug": debug,
      "devDevice": devDevice
    });
  }

  /// 异常推送
  Future<void> postException(
      {required dynamic error, required dynamic stackTrace}) async {
    return _channel.invokeMethod("postException", {
      "error": "$error",
      "stackTrace": "$stackTrace",
    });
  }

  /// 设置用户id
  Future<void> setUserId({dynamic userId}) async {
    return _channel.invokeMethod("setUserId", {"userId": "id:$userId"});
  }

  /// 自定义信息
  Future<void> putUserData({dynamic key, dynamic value}) async {
    return _channel.invokeMethod("putUserData", {"key": key, "value": value});
  }

  /// IOS 异常测试
  Future<void> testIOSCrash() async {
    return _channel.invokeMethod("testIOSCrash");
  }

  /// 安卓异常测试
  Future<void> testJavaCrash() async {
    if (Platform.isIOS) {
      return Future.value();
    }
    return _channel.invokeMethod("testJavaCrash");
  }

  Future<void> checkUpgrade() async {
    if (Platform.isIOS) {
      return Future.value();
    }
    return _channel.invokeMethod("checkUpgrade");
  }

  final _obfuscatedStackTraceLineRegExp =
      RegExp(r'^(\s*#\d{2} abs )([\da-f]+)((?: virt [\da-f]+)?(?: .*)?)$');

  /// Returns a [List] containing detailed output of each line in a stack trace.
  List<Map<String, String>> _getStackTraceElements(StackTrace stackTrace) {
    final Trace trace = Trace.parseVM(stackTrace.toString()).terse;
    final List<Map<String, String>> elements = <Map<String, String>>[];

    if (_currentRoute?.isNotEmpty == true) {
      elements.add(<String, String>{
        'route': _currentRoute ?? "",
      });
    }
    for (final Frame frame in trace.frames) {
      if (frame is UnparsedFrame) {
        if (_obfuscatedStackTraceLineRegExp.hasMatch(frame.member)) {
          // Same exceptions should be grouped in Crashlytics Console.
          // Crashlytics Console groups issues with same stack trace.
          // Obfuscated stack traces contains abs address, virt address
          // and symbol name + offset. abs addresses are different across
          // sessions, so same error can create different issues in Console.
          // We replace abs address with '0' so that Crashlytics Console can
          // group same exceptions. Also we don't need abs addresses for
          // deobfuscating, if we have virt address or symbol name + offset.
          final String method = frame.member.replaceFirstMapped(
              _obfuscatedStackTraceLineRegExp,
              (match) => '${match.group(1)}0${match.group(3)}');
          elements.add(<String, String>{
            'file': '',
            'line': '0',
            'method': method,
          });
        }
      } else {
        final Map<String, String> element = <String, String>{
          'file': frame.library,
          'line': frame.line?.toString() ?? '0',
        };
        final String member = frame.member ?? '<fn>';
        final List<String> members = member.split('.');
        if (members.length > 1) {
          element['method'] = members.sublist(1).join('.');
          element['class'] = members.first;
        } else {
          element['method'] = member;
        }
        elements.add(element);
      }
    }

    return elements;
  }
}
