//
//  TodoNotificationManager.swift
//  Todolist
//
//  Created by Clément FLORET on 25/02/2022.
//

import Foundation
import SwiftUI

class TodoNotificationManager {
    var notificationCenter: UNUserNotificationCenter
    var sound: Bool = false
    var badge: Bool = false
    var notificationsScheduledCount: Int = 0
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        
        // Set Date/Time Style
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        // Set Locale
        dateFormatter.locale = .current
        
        return dateFormatter
    }
    
    init() {
        notificationCenter = UNUserNotificationCenter.current()
        requestAuthorization()
        setSoundSetting()
    }
    
    func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted == true && error == nil {
                print("Notifications permitted")
            } else {
                print("Notifications not permitted")
            }
        }
    }
    
    func setSoundSetting() {
        notificationCenter.getNotificationSettings { settings in
            guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else { return }
            if settings.soundSetting == .enabled {
                self.sound = true
            } else {
                self.sound = false
            }
            if settings.badgeSetting == .enabled {
                self.badge = true
            } else {
                self.badge = false
            }
        }
    }
    
    func addNotification(notification: TodoNotificationVM) {
        let content = UNMutableNotificationContent()
        
        // set title
        content.title = notification.title
        
        // set subtitle
        let dateFormatter = DateFormatter()
        /// Set Date/Time Style
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        /// Set Locale
        dateFormatter.locale = .current
        
        content.subtitle = notification.subtitle
        
        // set body
        content.body = dateFormatter.string(from: notification.date)
        
        // set sound
        if sound {
            content.sound = UNNotificationSound.default
        }
        
        // set badge
        if badge {
            self.notificationCenter.getPendingNotificationRequests(completionHandler: { notifications in
                self.notificationsScheduledCount = notifications.count
            })
            content.badge = NSNumber(value: notificationsScheduledCount)
        }
        
        // set date
        var date = DateComponents()
        let calendar = Calendar.current
        date.calendar = calendar
        date.minute = calendar.component(.minute, from: notification.date)
        date.hour = calendar.component(.hour, from: notification.date)
        date.day = calendar.component(.day, from: notification.date)
        date.month = calendar.component(.month, from: notification.date)
        date.year = calendar.component(.year, from: notification.date)
        if !date.isValidDate {
            print("Date is not valid")
            return
        }
        
        // set trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        // set identifier
        let identifier = notification.identifier
        
        // create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // add notification to notificationCenter
        notificationCenter.add(request, withCompletionHandler: nil)
    }
    
    func removeNotifications(with identifiers: [String]) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
