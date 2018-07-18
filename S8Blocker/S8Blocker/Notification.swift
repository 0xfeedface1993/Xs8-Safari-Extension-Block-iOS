//
//  Notification.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/7/12.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import WebShell_iOS
import UserNotifications

extension AppDelegate {
    func sendDownloadFinishedNotification(task: PCDownloadTask) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        if let _ = task.pack.error {
            content.title = "下载完成"
            content.body = "\(task.fileName)下载成功，点击进入App继续"
        }   else    {
            content.title = "下载失败"
            content.body = "\(task.fileName)下载失败，点击进入App继续"
        }
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
        let request = UNNotificationRequest(identifier: task.fileName, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let e = error {
                print(e)
            }
        }
    }
}
