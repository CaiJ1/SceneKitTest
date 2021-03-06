#
# Be sure to run `pod lib lint JCModuleDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'JCModuleDemo'
  s.version          = '0.1.0'
  s.summary          = 'A short description of JCModuleDemo.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jiacai/JCModuleDemo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jiacai' => '1127462679@qq.com' }
  s.source           = { :git => 'https://github.com/jiacai/JCModuleDemo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = "JCModuleDemo/Classes/**/*", "JCModuleDemo/Classes/**/*.{h,hpp,m,mm,cpp}"
  
  # s.resource_bundles = {
  #   'JCModuleDemo' => ['JCModuleDemo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  ## 仅修改pod模块工程
  s.pod_target_xcconfig = {
  ## 修改应用framework 的工程
  #s.xcconfig = {
  #    'OTHER_LDFLAGS' => '-undefined dynamic_lookup',
  #    'OTHER_LDFLAGS' => '-framework Masonry',
      'ENABLE_BITCODE' => 'NO',
      'FRAMEWORK_SEARCH_PATHS' => '"$(PODS_TARGET_SRCROOT)/**"',
      'HEADER_SEARCH_PATHS' => '"$(PODS_ROOT)/../../**"'
  }
end
