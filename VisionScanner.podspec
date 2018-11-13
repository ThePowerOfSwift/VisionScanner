#
# Be sure to run `pod lib lint VisionScanner.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'VisionScanner'
  s.version          = '1.0.1'
  s.summary          = 'Start scanning barcodes using Apple\'s Vision Framework.'

  s.description      = <<-DESC
This pod allows you to easily start scanning barcodes using Apple's Vision Framework.
It provides you with a ViewController (an instance of VisionScannerViewController)
with a single video output preview view. This controller exposes four functions
func stopScan(completion:), func pauseScan(completion:), func resetScan() and
func startScan(completion:).
                       DESC

  s.homepage         = 'https://github.com/aldo-dev/VisionScanner.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ALDO Inc' => 'aldodev@aldogroup.com' }
  s.source           = { :git => 'https://github.com/aldo-dev/VisionScanner.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'
  s.swift_version   = '4.2'
                       
  s.source_files = 'VisionScanner/Classes/**/*'

end
