Pod::Spec.new do |s|
  s.name     = 'IBHeatMap'
  s.version  = '1.0'
  s.platform = :ios
  s.license  = 'MIT'
  s.summary  = 'IBHeatMap is a simple to use HeatMap generator for iOS.'
  s.homepage = 'https://github.com/ivanbruel/IBHeatMap'
  s.author   = { 'Ivan Bruel' => 'ivan.bruel@gmail.com' }
  s.source   = { :git => 'https://github.com/ivanbruel/IBHeatMap.git', :tag => s.version.to_s }

  s.description = 'IBHeatMap is a simple to use (although a bit slow) HeatMap generator for iOS. All it is required are points, radius and colors and it will generate a HeatMap on top of your desired content.'

  s.source_files = 'IBHeatMap/IBHeatMap/*.{h,m}'
  s.framework    = 'QuartzCore'
  s.requires_arc = true
end