//
//  UIFunction.swift
//  TabViewTest
//
//  Created by Ben_Mac on 2017/12/21.
//  Copyright © 2017年 Ben_Mac. All rights reserved.
//

import Foundation
import UIKit

class UIObject {
    var deviceName = ""  //取得設備名稱 如 iPhone 5
    var sysName = "" //取得系統名稱 如：iPhone OS
    var sysVersion = ""  //取得系统版本 如：10.3
    var deviceUUID = ""  //取得設備UUID
    var deviceModel = "" //取得設備的型號 如：iPhone

    init() {
        
        let deviceName = UIDevice.current.name  //取得設備名稱 如 iPhone 5
        let sysName = UIDevice.current.systemName //取得系統名稱 如：iPhone OS
        let sysVersion = UIDevice.current.systemVersion //取得系统版本 如：10.3
        let deviceUUID = UIDevice.current.identifierForVendor?.uuidString  //取得設備UUID
        let deviceModel = UIDevice.current.model //取得設備的型號 如：iPhone
        print("DeviceName: \(deviceName) DeviceSystem: \(sysName) SystemVerion: \(sysVersion) UUID: \(String(describing: deviceUUID)) Modal: \(deviceModel)")
        self.deviceModel = deviceModel
        self.sysName = sysName
        self.sysVersion = sysVersion
        self.deviceUUID = deviceUUID!
        self.deviceModel = deviceModel
        
    }
    
    
    func showMessage(parent: UIViewController , msg:String, boxTitle:String) {
        let alertController = UIAlertController(title: boxTitle, message: msg, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "確定", style: UIAlertAction.Style.default, handler: nil))
        DispatchQueue.main.async { // Correct
          parent.present(alertController, animated: true, completion: nil)
        }
    }
    
}

