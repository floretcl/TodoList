//
//  TodoListsVM.swift
//  Todolist
//
//  Created by Clément FLORET on 10/01/2022.
//

import Foundation
import CoreData
import SwiftUI

class TodoListsVM: ObservableObject {
    let persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext
    var listsCoreData: [TodoList] = []
    @Published var lists: [TodoListVM] = []
    
    init() {
        // initalize viewContext
        self.viewContext = persistenceController.container.viewContext
    }
    
    func saveViewContext() {
        do {
            try self.viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllTodoListsByOrder(ascending: Bool) {
        // create fetchRequest
        let fetchRequest = NSFetchRequest<TodoList>(entityName: "TodoList")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TodoList.index, ascending: ascending)]
        do {
            // save results in listsCoreData array of TodoList
            self.listsCoreData = try self.viewContext.fetch(fetchRequest)
            // conevrt and save results in lists array of TodoListVM
            self.lists = self.listsCoreData.map { todoList in
                TodoListVM(todolist: todoList)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func addList(listVM: TodoListVM) {
        // reorganize order of others lists if necessary
        if listsCoreData.count != 0 {
            for n in 0...(listsCoreData.count - 1) {
                self.listsCoreData[n].index += 1
            }
        }
        // create new TodolList to CoreData and save
        _ = listVM.convertToTodoList(viewContext: self.viewContext)
        self.saveViewContext()
    }
    
    func moveList(index: Int, destination: Int) {
        var newIndex: Int = 0
        // reorganize manual order
        // If selected list moving down, reorganize upper others lists
        if index < destination {
            newIndex = destination - 1
            for n in 1...(newIndex - index) {
                self.listsCoreData[(index + n)].index = Int64(index + (n - 1))
            }
            // If selected list moving up, reorganize lower others lists
        } else if index > destination {
            newIndex = destination
            for n in 1...(index - newIndex) {
                self.listsCoreData[(newIndex + (n - 1))].index = Int64(newIndex + n)
            }
        } else {
            return
        }
        // move selected list and save
        self.listsCoreData[index].index = Int64(newIndex)
        self.saveViewContext()
    }
    
    func modifyTodo(listVM: TodoListVM, name: String, image: TodoListVM.ListImage, color: TodoListVM.ListColor) {
        for list in listsCoreData {
            if list.index == listVM.index {
                list.name = name
                list.imageName = image.name
                list.colorName = color.name
            }
        }
        self.saveViewContext()
    }
    
    func removeList(index: Int) {
        // reorganize lists order of others lists before
        if listsCoreData[index].index < (lists.count - 1) {
            for n in (index + 1)...(lists.count - 1) {
                self.listsCoreData[n].index -= 1
            }
        }
        // then delete selected List of CoreData and save
        self.viewContext.delete(listsCoreData[index])
        self.saveViewContext()
    }
    
    func getTodoList(todoListVM: TodoListVM) -> TodoList? {
        // get selected TodoList from CoreData
        guard let index = listsCoreData.firstIndex(where: { todoList in
            todoList.index == todoListVM.index
        }) else { return nil }
        return listsCoreData[index]
    }
    
    func listNameAlreadyExist(name: String) -> Bool {
        for list in lists {
            if list.name.lowercased() == name.lowercased() {
                return true
            }
        }
        return false
    }
}
