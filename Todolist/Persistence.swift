//
//  Persistence.swift
//  Todolist
//
//  Created by Clément FLORET on 14/12/2021.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newTodoList = TodoList(context: viewContext)
        newTodoList.id = UUID()
        newTodoList.name = "Todo list"
        newTodoList.colorName = "purple"
        newTodoList.imageName = "list.bullet"
        newTodoList.dateAdded = Date()
        for i in 0..<5 {
            let newTodoList = TodoList(context: viewContext)
            newTodoList.id = UUID()
            newTodoList.name = "Todo list \(i)"
            newTodoList.colorName = "blue"
            newTodoList.imageName = "list.bullet"
            newTodoList.dateAdded = Date()
            for j in 0..<i {
                let newTodo = Todo(context: viewContext)
                newTodo.id = UUID()
                newTodo.name = "Todo n°\(j) list \(i)"
                newTodo.list = newTodoList
                newTodo.priority = "Medium"
                newTodo.dateAdded = Date()
                newTodo.dateTodo = Date()
                newTodo.done = false
            }
        }
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Todolist")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })
    }
}
