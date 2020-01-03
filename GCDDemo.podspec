Pod::Spec.new do |s|
    s.name = 'GCDDemo'
    s.version = '1.0.1'
    s.license = 'MIT'
    s.summary = 'GCDDemo'
    s.homepage = 'https://github.com/CCRogerWang/GCDDemo'
    s.authors = { 'roger.wang' => 'roger77622@gmail.com' }
    s.source = { :git => 'https://github.com/CCRogerWang/GCDDemo.git', :tag => s.version }
      
    s.ios.deployment_target = '13.0' 
    s.source_files = 'GCDDemoMobile/*.swift'
end