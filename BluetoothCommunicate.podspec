Pod::Spec.new do |s|
  s.name         = "BluetoothCommunicate"
  s.version      = "0.0.2"
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
  s.source_files  = "AccBluetoothCommunicate/AccBluetoothCommunicate.h",'AccBluetoothCommunicate/*.{h,m}'
  #s.subs "BabyBluetooth" do |ss|
  #    	ss.source_files = "AccBluetoothCommunicate/BabyBluetooth/*.{h,m}"
  #   	ss.iOS.frameworks = "CoreBluetooth"
  #end
  #s.subs "Protocol" do |ss|
  #	ss.source_files = "AccBluetoothCommunicate/Protocol/*h"
  #end
  #s.subs "TaskManager" do |ss|
  #	ss.source_files = "AccBluetoothCommunicate/TaskManager/*{h,m}"
  #	#ss.dependency "AccBluetoothCommunicate/CommandTaskProtocol.h"
  #	#ss.dependency "AccBluetoothCommunicate/BabyBluetooth"
  #end
  s.requires_arc = true
  s.ios.framework = 'Foundation'
end
