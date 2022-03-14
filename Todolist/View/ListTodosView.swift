//
//  ListTodosView.swift
//  Todolist
//
//  Created by Clément FLORET on 07/02/2022.
//

import SwiftUI

struct ListTodosView: View {
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todoNotificationsManagerVM: TodoNotificationsManagerVM
    
    @AppStorage("show-todos-done") var showTodosDone: Bool = false
    
    var list: TodoListVM
    
    @State var needUpdate: Bool = false
    @State var selection = Set<UUID>()
    @State var editMode: EditMode = .inactive
    
    @State var showAddView: Bool = false
    
    var body: some View {
        VStack {
            TodosList(
                showTodosDone: _showTodosDone,
                list: list,
                selection: $selection,
                needUpdate: $needUpdate,
                editMode: $editMode)
        }
        .padding(.bottom, 1)
        .navigationTitle(list.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            TodosListToolbar(
                showTodosDone: _showTodosDone,
                selection: selection,
                toSetDone: self.toSetDone(ids: selection),
                needUpdate: $needUpdate,
                editMode: $editMode,
                showAddView: $showAddView,
                setDoneSelected: {
                    self.setDoneSelected(ids: selection, setDone: self.toSetDone(ids: selection))
                },
                deleteSelected: {
                    self.deleteSelected(ids: selection)
                })
        }
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showAddView, onDismiss: {
            needUpdate = true
        }, content: {
            AddTodoView(list: list)
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        })
        .onChange(of: editMode) { value in
            if value == .inactive {
                selection = []
            }
        }
        .onChange(of: needUpdate) { value in
            if value {
                self.update()
            }
        }
    }
    
    func setDoneSelected(ids: Set<UUID>, setDone: Bool) {
        for todo in todosVM.todos {
            if ids.contains(todo.id) {
                todosVM.setTodoDone(todoVM: todo, isDone: setDone)
                self.update()
            }
        }
        selection = []
        editMode = .inactive
        needUpdate = true
    }
    
    func deleteSelected(ids: Set<UUID>) {
        for todo in todosVM.todos {
            if ids.contains(todo.id) {
                todosVM.removeTodo(todoVM: todo)
            }
        }
        selection = []
        editMode = .inactive
        needUpdate = true
    }
    
    func toSetDone(ids: Set<UUID>) -> Bool {
        var containsDone: Bool = false
        var containsNoDone: Bool = false
        for todo in todosVM.todos {
            if ids.contains(todo.id) {
                if todo.done == true {
                    containsDone = true
                } else {
                    containsNoDone = true
                }
            }
        }
        if containsDone && !containsNoDone {
            return false
        } else {
            return true
        }
    }
    
    func update() {
        todosVM.fetchAllTodosByOrder(ascending: true)
        todoListsVM.fetchAllTodoListsByOrder(ascending: true)
        needUpdate = false
    }
}

struct ListTodosView_Previews: PreviewProvider {
    static var previews: some View {
        ListTodosView(list: TodoListVM(name: "List", image: .list, color: .blue, dateAdded: Date(), index: 0))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
            .environmentObject(TodoListsVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
