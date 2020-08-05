#
# Be sure to run `pod lib lint HHTableListViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HHTableListViewController'
  s.version          = '0.1.3'
  s.summary          = '封装tableView基类'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = '封装tableView基类 刷新自动加载更多'

  s.homepage         = 'https://github.com/huicuihui/HHTableListViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '805988356@qq.com' => '805988356@qq.com' }
  s.source           = { :git => 'https://github.com/huicuihui/HHTableListViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'HHTableListViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'HHTableListViewController' => ['HHTableListViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 4.0'
  s.dependency 'MJRefresh'
  s.dependency 'Masonry'
end
