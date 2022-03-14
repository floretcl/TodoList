//
//  TodosVM.swift
//  Todolist
//
//  Created by Clément FLORET on 10/01/2022.
//

import Foundation
import CoreData

class TodosVM: ObservableObject {
    let persistenceController = PersistenceController.shared
    var viewContext: NSManagedObjectContext
    var predicateString: String?
    var todosCoreData: [Todo] = []
    @Published var todos: [TodoVM] = []
    
    init() {
        self.viewContext = persistenceController.container.viewContext
    }
    
    func saveViewContext() {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchAllTodosByOrder(ascending: Bool) {
        // create fetchRequest
        let fetchRequest = NSFetchRequest<Todo>(entityName: "Todo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.index, ascending: ascending)]
        do {
            // save results in todosCoreData array of Todo
            self.todosCoreData = try viewContext.fetch(fetchRequest)
            // convert and save results in todos array of TodoVM
            self.todos = self.todosCoreData.map { todo in
                TodoVM(todo: todo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchTodosOfSearchByName(predicateString: String?, ascending: Bool) {
        // create fetchRequest and predicate
        self.predicateString = predicateString
        let fetchRequest = NSFetchRequest<Todo>(entityName: "Todo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.name, ascending: ascending)]
        if let search = predicateString, !search.isBlank {
            let predicate = NSPredicate(format: "name CONTAINS[c] %@", search)
            fetchRequest.predicate = predicate
        }
        do {
            // save results in todosCoreData array of Todo
            self.todosCoreData = try viewContext.fetch(fetchRequest)
            // convert and save results in todos array of TodoVM
            self.todos = self.todosCoreData.map { todo in
                TodoVM(todo: todo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchTodosOfListByOrder(predicateString: String?, ascending: Bool) {
        // create fetchRequest and predicate
        self.predicateString = predicateString
        let fetchRequest = NSFetchRequest<Todo>(entityName: "Todo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Todo.index, ascending: ascending)]
        if let list = predicateString, !list.isBlank {
            let predicate = NSPredicate(format: "name == %@", list)
            fetchRequest.predicate = predicate
        }
        do {
            // save results in todosCoreData array of Todo
            self.todosCoreData = try viewContext.fetch(fetchRequest)
            // convert and save results in todos array of TodoVM
            self.todos = self.todosCoreData.map { todo in
                TodoVM(todo: todo)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func todosToday() -> [TodoVM] {
        return todos.filter { todo in
            if let date = todo.dateTodo {
                return date.isToday()
            } else {
                return false
            }
        }
    }
    
    func todosScheduled() -> [TodoVM] {
        return todos.filter { todo in
            todo.dateTodo != nil
        }
    }
    
    func todosPriority(name: String) -> [TodoVM] {
        return todos.filter { todo in
            todo.priority.name == name
        }
    }
    
    func todosNotDone() -> [TodoVM] {
        return todos.filter({ todo in
            todo.done == false
        })
    }
    
    func todosNotDoneAndToday() -> [TodoVM] {
        return todos.filter({ todo in
            if let date = todo.dateTodo {
                return (date.isToday()) && (todo.done == false)
            } else {
                return false
            }
        })
    }
    
    func todosNotDoneAndScheduled() -> [TodoVM] {
        return todos.filter { todo in
            (todo.dateTodo != nil) && (todo.done == false)
        }
    }
    
    func todosNotDoneAndPriority(name: String) -> [TodoVM] {
        return todos.filter { todo in
            (todo.priority.name == name) && (todo.done == false)
        }
    }
    
    func addTodo(todoVM: TodoVM, todoList: TodoList) {
        // reorganize index if necessary
        if todosCoreData.count != 0 {
            for n in 0...(todosCoreData.count - 1) {
                self.todosCoreData[n].index += 1
            }
        }
        // create new Todo for CoreData
        let newTodo = todoVM.convertToTodo(viewContext: viewContext)
        
        // add list propriety and save Todo to CoreData
        newTodo.list = todoList
        saveViewContext()
    }
    
    func moveTodo(index: Int, destination: Int) {
        var newIndex: Int = 0
        // reorganize manual index
        // If selected list moving down, reorganize upper others todos
        if index < destination {
            newIndex = destination - 1
            for n in 1...(newIndex - index) {
                self.todosCoreData[(index + n)].index = Int64(index + (n - 1))
            }
            // If selected list moving up, reorganize lower others lists
        } else if index > destination {
            newIndex = destination
            for n in 1...(index - newIndex) {
                self.todosCoreData[(newIndex + (n - 1))].index = Int64(newIndex + n)
            }
        } else {
            return
        }
        // move selected list and save
        self.todosCoreData[index].index = Int64(newIndex)
        self.saveViewContext()
    }
    
    func moveTodoInList(index: Int, destination: Int, list: [TodoVM]) {
        let todoIndex = list[index].index
        var newTodoIndex: Int = 0
        var movedTodo: Todo?
        
        // get the moved todo from CoreData
        for todo in todosCoreData {
            if todo.index == todoIndex {
                movedTodo = todo
            }
        }
        
        // reorganize manual index
        // If selected todo moving down
        if index < destination {
            //get the new index for the moved todo
            newTodoIndex = list[destination - 1].index
            // reorganize upper others todos
            for n in 1...(newTodoIndex - todoIndex) {
                self.todosCoreData[(todoIndex + n)].index = Int64(todoIndex + (n - 1))
            }
            // If selected todo moving up
        } else if index > destination {
            //get the new index for the moved todo
            newTodoIndex = list[destination].index
            // reorganize lower others todos
            for n in 1...(todoIndex - newTodoIndex) {
                self.todosCoreData[(newTodoIndex + (n - 1))].index = Int64(newTodoIndex + n)
            }
        } else {
            return
        }
        
        // move selected list and save
        movedTodo?.index = Int64(newTodoIndex)
        self.saveViewContext()
    }
    
    func modifyTodo(todoVM: TodoVM, name: String, dateTodo: Date?, priority: TodoVM.TodoPriority, todoList: TodoList, done: Bool) {
        for todo in todosCoreData {
            if todo.index == todoVM.index {
                todo.name = name
                todo.dateTodo = dateTodo
                todo.priority = priority.name
                todo.list = todoList
            }
        }
        self.saveViewContext()
        
        self.setTodoDone(todoVM: todoVM, isDone: done)
    }
    
    func removeTodo(todoVM: TodoVM) {
        // get selected Todo from CoreData
        guard let index = todosCoreData.firstIndex(where: { todoCoreData in
            todoCoreData.index == todoVM.index
        }) else { return }
        let todo = todosCoreData[index]
        
        // delete it in coreData
        viewContext.delete(todo)
        
        // then reorganize manual index of others Todos and save
        let indexTodo = Int(todo.index)
        if todosCoreData[index].index < (todos.count - 1) {
            for n in (indexTodo + 1)...(todos.count - 1) {
                self.todosCoreData[n].index -= 1
            }
        }
        saveViewContext()
    }
    
    func removeTodoByIndex(index: Int) {
        // delete Todo of CoreData
        viewContext.delete(todosCoreData[index])
        
        // then reorganize index of others Todos and save
        let indexTodo = Int(todosCoreData[index].index)
        if todosCoreData[index].index < (todos.count - 1) {
            for n in (indexTodo + 1)...(todos.count - 1) {
                self.todosCoreData[n].index -= 1
            }
        }
        saveViewContext()
    }
    
    func removeTodoByList(list: [TodoVM], index: Int) {
        // find index of selected Todo
        let indexTodo = list[index].index
        
        // delete Todo of CoreData
        for todo in todosCoreData {
            if indexTodo == todo.index {
                viewContext.delete(todo)
            }
        }
        // then reorganize index of others Todos and save
        if indexTodo < (todos.count - 1) {
            for n in (indexTodo + 1)...(todos.count - 1) {
                self.todosCoreData[n].index -= 1
            }
        }
        saveViewContext()
    }
    
    func removeTodosDone() {
        // for every Todo done of CoreData
        for todo in todosCoreData {
            if todo.done {
                
                // delete Todo done
                viewContext.delete(todo)
                
                // then reorganize index of others todos
                let indexTodo = Int(todo.index)
                if indexTodo < (todos.count - 1) {
                    for n in (indexTodo + 1)...(todos.count - 1) {
                        self.todosCoreData[n].index -= 1
                    }
                }
            }
        }
        saveViewContext()
    }
    
    func removeTodosDoneByList(list: [TodoVM]) {
        // for each todo done from given list
        for todoVM in list {
            //search the corresponding todo
            for todo in todosCoreData {
                if (todo.index == todoVM.index) && todoVM.done {
                    // then delete Todo done
                    viewContext.delete(todo)
                    
                    // then reorganize index of others todos
                    let indexTodo = Int(todo.index)
                    if indexTodo < (todos.count - 1) {
                        for n in (indexTodo + 1)...(todos.count - 1) {
                            self.todosCoreData[n].index -= 1
                        }
                    }
                }
            }
        }
        saveViewContext()
    }
    
    func setTodoDone(todoVM: TodoVM, isDone: Bool) {
        // get selected Todo from CoreData
        guard let index = todosCoreData.firstIndex(where: { todo in
            todo.index == todoVM.index
        }) else { return }
        let todo = todosCoreData[index]
        
        // toggle todo done property
        todo.done = isDone
        
        // reorganize index of others todos and save
        let indexTodo = Int(todo.index)
        if isDone {
            // reorganize upper others todos
            if indexTodo < (todos.count - 1) {
                for n in (indexTodo + 1)...(todos.count - 1) {
                    self.todosCoreData[n].index -= 1
                }
                // then todo selected go down
                todo.index = Int64(todos.count - 1)
            }
        } else {
            if indexTodo != 0 {
                // reorganize lower others todos
                for n in 0...(indexTodo) {
                    self.todosCoreData[n].index += 1
                }
                // todo selected go up
                todo.index = 0
            }
        }
        saveViewContext()
    }
    
    func getTodosCount() -> Int {
        return todos.count
    }
    
    func getTodosDoneCount(list: [TodoVM]) -> Int {
        var count: Int = 0
        for todo in list {
            if todo.done {
                count += 1
            }
        }
        return count
    }
    
    func getTodosWithDateReminderCount() -> Int {
        var count: Int = 0
        for todo in todos {
            if todo.dateTodo != nil {
                count += 1
            }
        }
        return count
    }
    
    func getTodosDoneWithDateReminderCount() -> Int {
        var count: Int = 0
        for todo in todos {
            if (todo.dateTodo != nil) && (todo.done) {
                count += 1
            }
        }
        return count
    }
    
    func getTodosWithDateTodayCount() -> Int {
        var count: Int = 0
        for todo in todos {
            // If a reminder date exist
            if let todoDate = todo.dateTodo {
                // add 1 to counter if the date is today
                let calendar = Calendar.current
                if (calendar.component(.day, from: todoDate)) == (calendar.component(.day, from: Date())) &&
                    (calendar.component(.month, from: todoDate)) == (calendar.component(.month, from: Date())) &&
                    (calendar.component(.year, from: todoDate)) == (calendar.component(.year, from: Date())) {
                    count += 1
                }
            }
        }
        return count
    }
    
    func getTodosDoneWithDateTodayCount() -> Int {
        var count: Int = 0
        // for each todoVM
        for todo in todos {
            if todo.done {
                // If a reminder date exist
                if let todoDate = todo.dateTodo {
                    // add 1 to counter if the date is today
                    let calendar = Calendar.current
                    if (calendar.component(.day, from: todoDate)) == (calendar.component(.day, from: Date())) &&
                        (calendar.component(.month, from: todoDate)) == (calendar.component(.month, from: Date())) &&
                        (calendar.component(.year, from: todoDate)) == (calendar.component(.year, from: Date())) {
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    func todoNameAlreadyExist(name: String) -> Bool {
        for todo in todos {
            if todo.name.uppercased() == name.uppercased() {
                return true
            }
        }
        return false
    }
}
