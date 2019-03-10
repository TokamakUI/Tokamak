#
# Be sure to run `pod lib lint Tokamak.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Tokamak'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Tokamak.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/maxdesiatov/Tokamak'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Max Desiatov' => 'max@desiatov.com' }
  s.source           = { :git => 'https://github.com/maxdesiatov/Tokamak.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MaxDesiatov'

  s.ios.deployment_target = '11.0'
  s.macos.deployment_target = '10.14'

  s.source_files = 'Sources/Tokamak/**/*'
  
  # s.resource_bundles = {
  #   'Tokamak' => ['Tokamak/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Sources/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
