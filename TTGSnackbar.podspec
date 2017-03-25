Pod::Spec.new do |s|
  s.name         = "TTGSnackbar"
  s.module_name  = "TTGSnackbar"
  s.version      = "1.5.2"
  s.summary      = "A Swift based implementation of the Android Snackbar for iOS. Show simple message and action button or custom view like a Toast."

  s.description  = <<-DESC
                   TTGSnackbar is useful for showing a brief message at the bottom of the screen with an action button.
                   It also supports showing icon image, two action buttons or custom content view.
                   It appears above all other elements on screen and only one can be displayed at a time.
                   It disappears after a timeout or after user click the action button.
                   DESC

  s.homepage     = "https://github.com/zekunyan/TTGSnackbar"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author             = { "zekunyan" => "zekunyan@163.com" }
  s.social_media_url   = "http://tutuge.me"

  s.platform     = :ios, "8.0"
  s.ios.deployment_target     = '8.0'
  s.source       = { :git => "https://github.com/zekunyan/TTGSnackbar.git", :tag => s.version.to_s }
  s.source_files = "TTGSnackbar/**/*.{h,swift}"
  s.requires_arc = true
end
