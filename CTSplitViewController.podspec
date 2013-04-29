Pod::Spec.new do |spec|
  spec.name         = 'CTSplitViewController'
  spec.version      = '1.0.0'
  spec.platform     = :ios, '5.0'
  spec.license      = 'MIT'
  spec.source       = { :git => 'https://github.com/ebf/CTSplitViewController.git', :tag => spec.version.to_s }
  spec.source_files = 'CTSplitViewController/*.{h,m}'
  spec.resources    = 'CTSplitViewController/CTSplitViewCornerImage.png'
  spec.frameworks   = 'Foundation', 'UIKit'
  spec.requires_arc = true
  spec.homepage     = 'https://github.com/ebf/CTSplitViewController'
  spec.summary      = 'ParentViewController that improves UISplitViewController.'
  spec.author       = { 'Oliver Letterer' => 'oliver.letterer@gmail.com' }
end