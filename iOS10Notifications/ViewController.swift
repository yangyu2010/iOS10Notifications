//
//  ViewController.swift
//  iOS10Notifications
//
//  Created by Young on 2016/12/20.
//  Copyright © 2016年 杨羽. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        UNUserNotificationCenter.current().delegate = self
    }

    //发送通知
    @IBAction func sendNotification(_ sender: Any) {
        
        sendLocalNotification()
    }
    
    
    
    //查看即将发送的通知
    @IBAction func showUnsendNotification(_ sender: Any) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("即将发生的通知\(requests)")
        }
    }
    
    //取消即将发送的通知
    @IBAction func removeUnsendNotification(_ sender: Any) {
        
        //根据通知的id来删除
//        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [])
        
        //删除所有
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    //查看已经发送的通知
    @IBAction func showSendedNotification(_ sender: Any) {
        
        UNUserNotificationCenter.current().getDeliveredNotifications { (notifications) in
            print("已经发送了的通知\(notifications)")
        }
    }
    
    //取消已经发送的通知
    @IBAction func removeSendedNotification(_ sender: Any) {
        
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [])
        
        //删除所有已经发送的
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
    }
    
}

extension ViewController {

    fileprivate func sendLocalNotification() {
    
        
        //1.拿到center发请求
        let center = UNUserNotificationCenter.current()
        
        
        //2.设置内容
        let identifier = "TestiOS10NotificationID"
        let content = UNMutableNotificationContent()
        content.body = "我是本地通知的内容"
        content.badge = 10
        content.sound = UNNotificationSound(named: "win.aac")
        content.title = "我是title"
        content.subtitle = "我是subtitle"
        content.userInfo = ["name" : "mahone" , "age" : 18 , "iOS" : 3.14]

        let attachmentIdentifier = "ImageAttachmentIdentifier"
        // 拿到本地的文件
        if let url = Bundle.main.url(forResource: "20111111331405192374.gif", withExtension: nil) {
            
            do {
                let attachment = try UNNotificationAttachment(identifier: attachmentIdentifier, url: url, options: nil)
                content.attachments = [attachment]
                
            } catch {
                print(error)
            }
        }
        
       
        //3.设置时间
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
        
        //4.设置快捷回复
        // .foreground 进去app回复 
        // .destructive 删除通知
        let action1 = UNNotificationAction(identifier: "HuiFu", title: "回复", options: .foreground)
        let action2 = UNNotificationAction(identifier: "JuJue", title: "拒绝", options: .destructive)
        let action3 = UNTextInputNotificationAction(identifier: "KuaiJieHuiFu", title: "快速回复", options: .foreground, textInputButtonTitle: "回复", textInputPlaceholder: "快点回复吧")
        let actions = [action1,action2,action3]
        
        // 创建操作组
        // identifier: 操作组标识
        // actions: 操作组行为
        // intentIdentifiers:暂时未发现该用途
        // options: 支持的场景
        let categoryIdentifier = "categoryID"
        let category = UNNotificationCategory(identifier: categoryIdentifier, actions: actions, intentIdentifiers: [], options: .customDismissAction)
        let set : Set<UNNotificationCategory> = [category]
        center.setNotificationCategories(set)
        
        // 设置该通知用到的额外操作组
        content.categoryIdentifier = categoryIdentifier
        
        
        //5.添加请求对象(request对象要放最后创建,有个顺序,不然自定义的action不会实现)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error == nil {
                print("添加本地通知成功")
            }else {
                print("添加本地通知失败")
                print(error!)
            }
        }

    }
}


// MARK: -通知的代理
extension ViewController : UNUserNotificationCenterDelegate {

    /// 当接收到通知的时候会来到该方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
//        print("接收到通知\(response)")
        
        //如果response是UNTextInputNotificationResponse 就是快速回复进入app的
        if let response = response as? UNTextInputNotificationResponse {
            print(response.userText)
        }else {
            //是直接点击通知进入app的
            print("接收到通知获取额外信息:\(response.notification.request.content.userInfo)")
        }
        
        let status = UIApplication.shared.applicationState
        
        switch status {
        case .active:
            //app在前台,收到通知 ,点击
            print("在前台")
        case .inactive:
            //从后台进入前台
            print("进入前台")
        case .background:
            print("后台")
        }
        
        completionHandler()
    }
    
    /// 当一个通知发送成功后会来到该方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        print("发送通知成功\(notification)")
        
        /// 在前台也能接收到通知
        completionHandler([.alert,.badge,.sound])
    }
}

