# Swift3.0_iOS10Notification
swift3.0,在iOS10下本地通知.

#1.先注册通知
     UNUserNotificationCenter.current.requestAuthorization(options: [.alert, .badge, .sound , .carPlay]) { (success, error) in
            if success {
                print("用户允许本地通知")
            }else {
                print("用户拒绝本地通知")
            }
        }
        
#2发送通知前的准备
1.拿到center
    	
    	let center = UNUserNotificationCenter.current()
        
2.设置内容相关
		
		let identifier = "TestiOS10NotificationID"
        let content = UNMutableNotificationContent()
        content.body = "我是本地通知的内容"
        content.badge = 10
        content.sound = UNNotificationSound(named: "win.aac")
        content.title = "我是title"
        content.subtitle = "我是subtitle"
        content.userInfo = ["name" : "yangyu" , "age" : 18 , "pi" : 3.14]     
        
3.iOS10通知可以添加图片,音视频了
		
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
        throws自己处理,resource本地资源
         

4.设置推送时间
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
		
5.iOS10后,社交聊天的APP在下拉通知后,就可以快速回复消息
	
	//4.设置快捷回复
        // .foreground 进去app回复 
        // .destructive 删除通知
        let action1 = UNNotificationAction(identifier: "HuiFu", title: "回复", options: .foreground)
        let action2 = UNNotificationAction(identifier: "JuJue", title: "拒绝", options: .destructive)
        let action3 = UNTextInputNotificationAction(identifier: "KuaiJieHuiFu", title: "快速回复", options: .foreground, textInputButtonTitle: "回复", textInputPlaceholder: "快点回复吧")
        let actions = [action1,action2,action3]

6.创建操作组

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
        
7.创建请求对象,发送通知

		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request) { (error) in
            if error == nil {
                print("添加本地通知成功")
            }else {
                print("添加本地通知失败")
                print(error!)
            }
        }


这样就可以收到推送了,监听推送用代理-UNUserNotificationCenterDelegate
		
		/// 当接收到通知的时候会来到该方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		//print("接收到通知\(response)")
		
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


以上可以实现一些iOS10通知消息的一些特性,远程推送的还没弄过,有机会可以试试!
以上内容是看到小码哥贴吧,整理的.原文字链接在下面.感谢!

http://bbs.520it.com/forum.php?mod=viewthread&tid=3020
