#
# Be sure to run `pod lib lint TokamakDemo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
s.name             = 'TokamakDemo'
s.version          = '0.1.2'
s.summary          = 'Demo components for Tokamak: React-like UI framework'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = <<-DESC
Tokamak provides a declarative, testable and scalable API for building UI
components backed by fully native views. You can use it for your new macOS apps
or add to existing apps with little effort and without rewriting the rest of
the code or changing the app's overall architecture.

Tokamak recreates React Hooks API improving it with Swift's strong type
system, high performance and efficient memory management thanks to being
compiled to a native binary.
DESC

s.homepage         = 'https://github.com/MaxDesiatov/Tokamak'
# s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
s.author           = { 'Max Desiatov' => 'max@desiatov.com' }
s.source           = {
:git => 'https://github.com/MaxDesiatov/Tokamak.git',
:tag => s.version.to_s
}
s.social_media_url = 'https://twitter.com/MaxDesiatov'

s.ios.deployment_target = '11.0'
s.macos.deployment_target = '10.14'
s.swift_version    = '4.2'

s.source_files = 'Sources/TokamakDemo/**/*'

# s.resource_bundles = {
#   'Tokamak' => ['Tokamak/Assets/*.png']
# }

# s.public_header_files = 'Pod/Sources/**/*.h'
s.dependency 'Tokamak', '~> 0.1'
end
