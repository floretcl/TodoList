//
//  TodoListVM.swift
//  Todolist
//
//  Created by Clément FLORET on 14/12/2021.
//

import Foundation
import CoreData
import SwiftUI

struct TodoListVM: Identifiable {
    var id: UUID
    var name: String
    var image: ListImage
    var color: ListColor
    var dateAdded: Date
    var index: Int
    var todos: [TodoVM]
    
    enum ListColor: String, CaseIterable, Identifiable {
        // iOS 14, *
        case blue = "blue"
        case gray = "gray"
        case green = "green"
        case orange = "orange"
        case pink = "pink"
        case purple = "purple"
        case red = "red"
        case yellow = "yellow"
        
        // iOS 15, *
        case brown = "brown"
        case cyan = "cyan"
        case indigo = "indigo"
        case mint = "mint"
        
        static var count: Int {
            if #available(iOS 15.0, *) {
                return 12 // Number of colors available for iOS5
            } else {
                return 8 // Number of colors available for iOS14
            }
        }
        var name: String { self.rawValue }
        var id: String { self.rawValue }
        
        func toColor() -> Color {
            switch self {
            case .blue:
                return Color.blue
            case .gray:
                return Color.gray
            case .green:
                return Color.green
            case .orange:
                return Color.orange
            case .pink:
                return Color.pink
            case .purple:
                return Color.purple
            case .red:
                return Color.red
            case .yellow:
                return Color.yellow
            case .brown:
                if #available(iOS 15.0, *) {
                    return Color.brown
                } else {
                    return Color.gray
                }
            case .cyan:
                if #available(iOS 15.0, *) {
                    return Color.cyan
                } else {
                    return Color.blue
                }
            case .indigo:
                if #available(iOS 15.0, *) {
                    return Color.indigo
                } else {
                    return Color.purple
                }
            case .mint:
                if #available(iOS 15.0, *) {
                    return Color.mint
                } else {
                    return Color.green
                }
            }
        }
    }
    
    enum ListImage: String, CaseIterable, Identifiable {
        case list = "list.bullet"
        case call = "phone"
        case mail = "envelope"
        case message = "bubble.left"
        case letter = "highlighter"
        case documents = "doc.on.doc"
        case bookmarks = "bookmark"
        case study = "graduationcap"
        case work = "briefcase"
        case time = "clock"
        case calendar = "calendar"
        case laptop = "laptopcomputer"
        case tv = "tv"
        case camera = "camera"
        case video = "play.rectangle"
        case game = "gamecontroller"
        case home = "house"
        case money = "creditcard"
        case shopping = "cart"
        case gift = "gift"
        case box = "shippingbox"
        case health = "stethoscope"
        case pills = "pills"
        case plant = "leaf"
        case craft = "wrench.and.screwdriver"
        case eye = "eye"
        case airplane = "airplane"
        case car = "car"
        case bus = "bus"
        case train = "tram"
        case activities = "figure.walk"
        case sport = "sportscourt"
        case book = "books.vertical"
        case cinema = "film"
        case concert = "music.note"
        case paint = "paintpalette"
        case photo = "photo.on.rectangle.angled"
        case music = "headphones"
        
        var name: String { self.rawValue }
        var id: String { self.rawValue }
    }
    
    // For Creation
    init(name: String, image: ListImage, color: ListColor, dateAdded: Date, index: Int) {
        self.id = UUID()
        self.name = name
        self.image = image
        self.color = color
        self.dateAdded = dateAdded
        self.index = index
        self.todos = []
    }
    
    // For Views
    init(todolist: TodoList) {
        self.id = todolist.id ?? UUID()
        self.name = todolist.name ?? "Todo"
        self.image = ListImage(rawValue: todolist.imageName ?? "list.bullet") ?? ListImage.list
        self.color = ListColor(rawValue: todolist.colorName ?? "gray") ?? ListColor.gray //TODO: to change to accentColor ?
        self.dateAdded = todolist.dateAdded ?? Date()
        self.index = Int(todolist.index)
        self.todos = []
        if let todos = todolist.todos?.array as? [Todo] {
            self.todos = todos.map({ todo in
                TodoVM(todo: todo)
            })
        }
    }
    
    // For Save To CoreData
    func convertToTodoList(viewContext: NSManagedObjectContext) -> TodoList {
        let todoList = TodoList(context: viewContext)
        todoList.id = UUID()
        todoList.name = name
        todoList.imageName = image.name
        todoList.colorName = color.name
        todoList.dateAdded = dateAdded
        todoList.index = Int64(index)
        return todoList
    }
    
    // todos count from a TodoList
    func getTodosCount() -> Int {
        return todos.count
    }
    
    // todos done count from TodoList
    func getDoneTodosCount() -> Int {
        var count: Int = 0
        for todo in todos {
            if todo.done {
                count += 1
            }
        }
        return count
    }
    
    // todos not done from TodoList
    func getTodosNotDone() -> [TodoVM] {
        return todos.filter { todo in
            todo.done == false
        }
    }
}
