Pod::Spec.new do |s|
  s.name         = "TMPhotoBrowerView"
  s.version      = "1.0"
  s.summary      = "photo brower"

  s.description  = <<-DESC
                  photo brower view
                   DESC

  s.homepage     = "https://github.com/tangshimi/TMPhotoBrowerView"

  s.license      = { :type => 'Copyright',
      :text => <<-LICENSE
      Copyright 2016 tangshimi. All rights reserved.
      LICENSE
 }
  s.author    = "tangshimi"
  s.platform     = :ios, "8.0"
  s.ios.deployment_target = "8.0"
  s.source       = { :git => "https://github.com/tangshimi/TMPhotoBrowerView.git",:tag => "1.0" }

  s.source_files  = "TMPhotoBrowerView/TMPhotoBrowerView/*.{h,m}"
  s.requires_arc = true
  s.dependency "SDWebImage", "~> 3.7.3"

end
