#
# Be sure to run `pod lib lint EVContactsPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EVContactsPicker"
  s.version          = "0.1.10"
  s.summary          = "A Contact Picker using Contacts Framework that allows any input source not just the Apple Contacts."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        Rewrite of THContactPicker in Swift with the following changes
                        1. uses Apples new ios9 Contacts and ContactsUI Frameworks
                        2. allows any contact source to be used as long as it conforms to the
                        EVCContactsPickerDataSourceProtocol Protocol.
                       DESC

  s.homepage         = "https://interlook.com"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'Proprietary'
  s.author           = { "Edward Valentini" => "edward@interlook.com" }
  s.source           = { :git => "ssh://git@git.timeraven.com/evcontactspicker.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'EVContactsPicker' => ['Pod/Assets/*']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
