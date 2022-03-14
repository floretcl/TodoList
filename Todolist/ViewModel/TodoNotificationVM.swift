//
//  TodoNotificationVM.swift
//  Todolist
//
//  Created by Clément FLORET on 23/02/2022.
//

import Foundation
import SwiftUI

struct TodoNotificationVM {
    var id: UUID
    var title: String
    var subtitle: String
    var date: Date
    var identifier: String
    
    init(title: String, subtitle: String, date: Date) {
        self.id = UUID()
        self.title = title
        self.subtitle = subtitle
        self.date = date
        self.identifier = UUID().uuidString
    }
}
