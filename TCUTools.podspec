Pod::Spec.new do |spec|
  spec.name 					= 'TCUTools'
  spec.version 					= '1.0.1'
  spec.authors 					= { 'Töre Çağrı Uyar' => 'mail@toreuyar.net' }
  spec.license 					= { :type => 'MIT' }
  spec.homepage					= 'https://github.com/toreuyar/TCUTools'
  spec.summary					= 'Helper classes for various needs coded on Objective-C, iOS.'
  spec.source       			= { :git => 'https://github.com/toreuyar/TCUTools.git',
  									:tag => spec.version.to_s,
  									:submodules => true }
  spec.source_files 			= '*.{h,m}'
  spec.platform 				= :ios
  spec.ios.deployment_target 	= "7.0"
  spec.requires_arc 			= true
  spec.framework    			= 'Foundation', 'UIKit'
  spec.xcconfig 				= { 'OTHER_LDFLAGS' => '-lObjC' }
end