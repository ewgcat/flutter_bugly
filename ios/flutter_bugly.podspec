#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_bugly.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_bugly'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter Bugly.'
  s.description      = <<-DESC
A new Flutter Bugly.
                       DESC
  s.homepage         = 'http://zj.tech'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'ZJ' => 'xuzhiquan@zj.tech' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'Bugly'
  s.platform = :ios, '9.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
