//
//  TodoVM.swift
//  Todolist
//
//  Created by Clément FLORET on 10/01/2022.
//

import Foundation
import CoreData

class TodoVM: Identifiable {    
    var id: UUID
    var name: String
    var dateAdded: Date
    var dateTodo: Date?
    var priority: TodoPriority
    var list: TodoListVM
    var done: Bool
    var index: Int
    var notificationIdentifier: String
    
    enum TodoPriority: String, CaseIterable, Identifiable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var name: String { self.rawValue }
        var id: String { self.rawValue }
    }
    
    // For Creation
    init(name: String, dateAdded: Date, dateTodo: Date?, priority: TodoPriority, list: TodoListVM, index: Int) {
        self.id = UUID()
        self.name = name
        self.dateAdded = dateAdded
        self.dateTodo = dateTodo
        self.priority = priority
        self.list = list
        self.done = false
        self.index = index
        self.notificationIdentifier = dateTodo != nil ? UUID().uuidString : ""
    }
    
    // For Views
    init(todo: Todo) {
        self.id = todo.id ?? UUID()
        self.name = todo.name ?? "Todo"
        self.dateAdded = todo.dateAdded ?? Date()
        self.dateTodo = todo.dateTodo ?? nil
        self.priority = TodoPriority.init(rawValue: todo.priority ?? "Medium") ?? .medium
        self.list = TodoListVM(
            name: (todo.list?.name)!,
            image: TodoListVM.ListImage(rawValue: (todo.list?.imageName)!) ?? .list,
            color: TodoListVM.ListColor(rawValue: (todo.list?.colorName)!) ?? .blue,
            dateAdded: (todo.list?.dateAdded)!,
            index: Int((todo.list?.index)!))
        self.done = todo.done
        self.index = Int(todo.index)
        self.notificationIdentifier = todo.notificationIdentifier ?? ""
    }
    
    // For Save To CoreData
    func convertToTodo(viewContext: NSManagedObjectContext) -> Todo {
        let todo = Todo(context: viewContext)
        todo.id = UUID()
        todo.name = self.name
        todo.dateAdded = self.dateAdded
        todo.dateTodo = self.dateTodo
        switch self.priority {
        case .low:
            todo.priority = "Low"
        case .medium:
            todo.priority = "Medium"
        case .high:
            todo.priority = "High"
        }
        todo.done = self.done
        todo.index = Int64(self.index)
        todo.notificationIdentifier = notificationIdentifier
        return todo
    }
}
