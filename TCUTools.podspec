Pod::Spec.new do |s|
  s.name             = "TCUTools"
  s.version          = "3.0.6"
  s.summary          = "Helper classes for various needs coded on Objective-C, iOS."
  s.homepage         = "https://github.com/toreuyar/TCUTools"
  s.license          = { :type => 'MIT' }
  s.author           = { "Töre Çağrı Uyar" => "mail@toreuyar.net" }
  s.source           = {  :git => 'https://github.com/toreuyar/TCUTools.git', :tag => s.version.to_s, :submodules => true }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'Pod/Classes/**/*'
  s.frameworks = 'UIKit', 'Foundation'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
end