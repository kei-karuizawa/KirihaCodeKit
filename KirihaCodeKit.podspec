#
# Be sure to run `pod lib lint KirihaCodeKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'KirihaCodeKit'
  spec.version          = '0.0.1'
  spec.summary          = 'A short description of KirihaCodeKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  spec.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  spec.homepage         = 'https://gitlab.com/kiriha/kiriha-code-kit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.author           = { '月见坂桐叶' => 'git_kiriha@163.com' }
  spec.source           = { :git => 'https://gitlab.com/kiriha/kiriha-code-kit.git', :tag => spec.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  spec.ios.deployment_target = "10.0"
  spec.swift_version = "5.0"
  spec.prefix_header_contents = '#import <Kiriha/kiriha-Swift.h>'
  
  spec.default_subspec = 'KCKCore'
  
  spec.subspec 'KCKCore' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKCore/**/*'
    ss.frameworks = "Foundation"
  end
  
  spec.subspec 'KCKFoundation' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKFoundation/**/*'
    ss.frameworks = "Foundation"
  end
  
  spec.subspec 'KCKCommon' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKCommon/**/*'
    ss.frameworks = "Foundation"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
  end
  
  # 通用 UIKit 组件
  spec.subspec 'KCKUIKit' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKUIKit/**/*'
    ss.frameworks = "Foundation", "UIKit"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
    ss.dependency 'KirihaCodeKit/KCKCommon'
    ss.dependency 'SDWebImage'
    ss.dependency 'SnapKit'
  end
  
  spec.subspec 'KCKView' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKView/*'
    ss.frameworks = "Foundation", "UIKit"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
    ss.dependency 'KirihaCodeKit/KCKCommon'
    ss.dependency 'KirihaCodeKit/KCKUIKit'
    ss.dependency 'SDWebImage'
    ss.dependency 'SnapKit'
  end
  
  # 底部 contentSheet 弹框
  spec.subspec 'KCKContentSheet' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKContentSheet/*'
    ss.frameworks = "Foundation", "UIKit"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
    ss.dependency 'KirihaCodeKit/KCKCommon'
    ss.dependency 'KirihaCodeKit/KCKUIKit'
    ss.dependency 'SnapKit'
  end
  
  # 警告框
  spec.subspec 'KCKAlertView' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKAlertView/*'
    ss.frameworks = "Foundation", "UIKit"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
    ss.dependency 'KirihaCodeKit/KCKCommon'
    ss.dependency 'KirihaCodeKit/KCKUIKit'
    ss.dependency 'SnapKit'
  end
  
  # 日历
  spec.subspec 'KCKCalendarView' do |ss|
    ss.source_files = 'KirihaCodeKit/Classes/KCKCalendarView/*'
    ss.frameworks = "Foundation", "UIKit"
    ss.dependency 'KirihaCodeKit/KCKFoundation'
  end
  
  spec.subspec "Resources" do |subspec|
    subspec.resource_bundles = {
      "KirihaCodeKit" => ["KirihaCodeKit/Assets/*.xcassets"]
    }
  end
  
  spec.static_framework = true
end
