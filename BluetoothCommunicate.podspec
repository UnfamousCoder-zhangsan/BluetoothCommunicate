Pod::Spec.new do |s|
  s.name         = "BluetoothCommunicate"
  s.version      = "0.0.3"
  s.summary      = "蓝牙指令发送"
  s.description  = <<-DESC
  蓝牙指令发送管理类工具
                   DESC
  s.homepage     = "https://github.com/UnfamousCoder-zhangsan/BluetoothCommunicate"
  s.license      = "MIT"
  s.author             = { "hi kobe" => "1546294949@qq.com" }
  s.platform     = :ios
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/UnfamousCoder-zhangsan/BluetoothCommunicate.git", :tag => "#{s.version}" }
  s.source_files  = 'AccBluetoothCommunicate/AccBluetoothCommunicate.h'
  s.subspec 'Protocol' do |ss|
    ss.source_files = 'AccBluetoothCommunicate/CommandTaskProtocol.h'
  end
  s.subspec 'BabyBluetooth' do |ss|
    ss.source_files = 'BabyBluetooth'
    ss.framework = 'CoreBluetooth'
  end
  s.subspec 'TaskManager' do |ss|
    ss.source_files = 'AccBluetoothCommunicate/AccBCCommandTaskManager.{h,m}'
    ss.dependency 'BluetoothCommunicate/BabyBluetooth'
    ss.dependency 'BluetoothCommunicate/Protocol'
  end
  s.requires_arc = true
  s.ios.framework = 'Foundation'
end
