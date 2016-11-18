Pod::Spec.new do |s|
  s.name             = "SwinjectStoryboard"
  s.version          = "1.0.0-beta.2"
  s.summary          = "Swinject extension for automatic dependency injection via Storyboard"
  s.description      = <<-DESC
                       SwinjectStoryboard is an extension of Swinject to automatically inject dependency to view controllers instantiated by a storyboard.
                       DESC
  s.homepage         = "https://github.com/Swinject/SwinjectStoryboard"
  s.license          = 'MIT'
  s.author           = 'Swinject Contributors'
  s.source           = { :git => "https://github.com/Swinject/SwinjectStoryboard.git", :tag => s.version.to_s }

  core_files = 'Sources/*.swift'
  umbrella_header_file = 'Sources/SwinjectStoryboard.h' # Must be at the end of 'source_files' to workaround CococaPods issue.
  s.ios.source_files = core_files, 'Sources/iOS-tvOS/*.{swift,h,m}', umbrella_header_file
  s.osx.source_files = core_files, 'Sources/OSX/*.{swift,h,m}', umbrella_header_file
  s.tvos.source_files = core_files, 'Sources/iOS-tvOS/*.{swift,h,m}', umbrella_header_file
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.dependency 'Swinject', '2.0.0-beta.2'
  s.requires_arc = true
end
