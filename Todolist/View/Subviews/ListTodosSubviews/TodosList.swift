//
//  TodosList.swift
//  Todolist
//
//  Created by Clément FLORET on 16/02/2022.
//

import SwiftUI

struct TodosList: View {
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoListsVM: TodoListsVM
    
    @AppStorage var showTodosDone: Bool
    
    var list: TodoListVM
    
    @Binding var selection: Set<UUID>
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    private var todosCount: Int {
        return list.getTodosCount()
    }
    private var todosDoneCount: Int {
        return list.getDoneTodosCount()
    }
    private var todos: [TodoVM] {
        return list.todos.sorted(by: {
            $0.index < $1.index
        })
    }
    private var todosNotDone: [TodoVM] {
        return list.getTodosNotDone().sorted(by: {
            $0.index < $1.index
        })
    }
    
    var body: some View {
        VStack {
            if showTodosDone {
                List(selection: $selection) {
                    Section {
                        if todosCount != 0 {
                            ForEach(todos) { todo in
                                TodoCell(
                                    todoVM: todo,
                                    withIcon: false,
                                    needUpdate: $needUpdate,
                                    editMode: $editMode)
                            }.onMove(perform: { indexSet, index in
                                self.moveItem(indexSet: indexSet, destination: index, list: todos)
                            })
                            .onDelete { indexSet in
                                self.deleteItem(list: todos, indexSet: indexSet)
                            }
                        } else {
                            Text("No Todos found")
                                .padding(20)
                        }
                    } header: {
                        HStack {
                            Text("\(todosDoneCount) Done -")
                            Button {
                                self.deleteTodosDone(list: list.todos)
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.accentColor)
                                    .disabled(todosDoneCount == 0 ? true : false)
                            }
                        }
                    }
                }
            } else {
                List(selection: $selection) {
                    if todosNotDone.count != 0 {
                        ForEach(todosNotDone) { todo in
                            TodoCell(
                                todoVM: todo,
                                withIcon: false,
                                needUpdate: $needUpdate,
                                editMode: $editMode)
                        }.onMove(perform: { indexSet, index in
                            self.moveItem(indexSet: indexSet, destination: index, list: todosNotDone)
                        })
                        .onDelete { indexSet in
                            self.deleteItem(list: todosNotDone, indexSet: indexSet)
                        }
                    } else {
                        Text("No Todos found")
                            .padding(20)
                    }
                }
            }
        }
        .onAppear {
            needUpdate = true
        }
        .listStyle(.insetGrouped)
    }
    
    func moveItem(indexSet: IndexSet, destination: Int, list: [TodoVM]) {
        // Change order of todolist in coreData
        for index in indexSet {
            todosVM.moveTodoInList(index: index, destination: destination, list: list)
        }
        needUpdate = true
    }
    
    func deleteItem(list: [TodoVM], indexSet: IndexSet) {
        for index in indexSet {
            todosVM.removeTodoByList(list: todos, index: index)
        }
        needUpdate = true
    }
    
    func deleteTodosDone(list: [TodoVM]) {
        todosVM.removeTodosDoneByList(list: list)
        needUpdate = true
    }
}

struct TodosList_Previews: PreviewProvider {
    static var previews: some View {
        TodosList(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), list: TodoListVM(name: "List", image: .list, color: .blue, dateAdded: Date(), index: 0), selection: .constant(Set<UUID>()), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
    }
}
