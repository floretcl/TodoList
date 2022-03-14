//
//  TodoNotificationsManagerVM.swift
//  Todolist
//
//  Created by Clément FLORET on 28/02/2022.
//

import Foundation

class TodoNotificationsManagerVM: ObservableObject {
    var todoNotificationManager = TodoNotificationManager()
    
    func addNotification(notification: TodoNotificationVM) {
        todoNotificationManager.addNotification(notification: notification)
    }
    
    func removeNotification(identifier: String) {
        todoNotificationManager.removeNotifications(with: [identifier])
    }
    
    func removeAllNotifications() {
        todoNotificationManager.removeAllNotifications()
    }
}
