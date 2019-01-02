#
# Be sure to run `pod lib lint EVContactsPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EVContactsPicker"
  s.version          = "0.6.0"
  s.summary          = "A Contact Picker using Contacts Framework that allows any input source not just the Apple Contacts."

  s.description      = <<-DESC
                        1. uses Apples new ios9 Contacts and ContactsUI Frameworks
                        2. allows any contact source to be used as long as it conforms to the
                        EVCContactsPickerDataSourceProtocol Protocol.
                       DESC

  s.homepage         = "https://github.com/edwardvalentini/EVContactsPicker"
  s.screenshots      = ["https://raw.githubusercontent.com/edwardvalentini/EVContactsPicker/master/Screenshots/screenshot0.png", "https://raw.githubusercontent.com/edwardvalentini/EVContactsPicker/master/Screenshots/screenshot1.png"]
  s.license          = 'MIT'
  s.author           = { "Edward Valentini" => "edward@interlook.com" }
  s.source           = { :git => "https://github.com/edwardvalentini/EVContactsPicker.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/edwardvalentini'

  s.platform     = :ios, '11.4'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'

  s.pod_target_xcconfig = {
                 'SWIFT_VERSION' => '4.2'
               }

  s.resource_bundles = {
                        'EVContactsPicker' => ['Pod/Assets/*'] #,'Pod/Assets/*.{png,gif,jpg}']
                      }
  s.dependency 'Nuke'

end
