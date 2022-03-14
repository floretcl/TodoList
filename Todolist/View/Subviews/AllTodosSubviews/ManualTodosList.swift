//
//  ManualTodosList.swift
//  Todolist
//
//  Created by Clément FLORET on 31/01/2022.
//

import SwiftUI

struct ManualTodosList: View {
    @EnvironmentObject var todosVM: TodosVM
    
    @AppStorage var showTodosDone: Bool
        
    @Binding var selection: Set<UUID>
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    private var numberOfDone: Int {
        return todosVM.getTodosDoneCount(list: todosVM.todos)
    }
    
    var body: some View {
        VStack {
            if showTodosDone {
                List(selection: $selection) {
                    Section {
                        if todosVM.todos.count != 0 {
                            ForEach(todosVM.todos) { todo in
                                TodoCell(
                                    todoVM: todo,
                                    withIcon: true,
                                    needUpdate: $needUpdate,
                                    editMode: $editMode)
                            }.onMove(perform: { indexSet, index in
                                self.moveItem(indexSet: indexSet, destination: index)
                            })
                            .onDelete { indexSet in
                                self.deleteItem(indexSet: indexSet)
                            }
                        } else {
                            Text("No Todos found")
                                .padding(20)
                        }
                    } header: {
                        HStack {
                            Text("\(numberOfDone) Done -")
                            Button {
                                self.deleteTodosDone()
                            } label: {
                                Text("Delete")
                                    .foregroundColor(.accentColor)
                                    .disabled(todosVM.getTodosDoneCount(list: todosVM.todos) == 0 ? true : false)
                            }
                        }
                    }
                }
            } else {
                List(selection: $selection) {
                    if todosVM.todosNotDone().count != 0 {
                        ForEach(todosVM.todosNotDone()) { todo in
                            TodoCell(
                                todoVM: todo,
                                withIcon: true,
                                needUpdate: $needUpdate,
                                editMode: $editMode)
                        }.onMove(perform: { indexSet, index in
                            self.moveItem(indexSet: indexSet, destination: index)
                        })
                        .onDelete { indexSet in
                            self.deleteItem(indexSet: indexSet)
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
    
    func moveItem(indexSet: IndexSet, destination: Int) {
        // Change order of todolist in coreData
        for index in indexSet {
            todosVM.moveTodo(index: index, destination: destination)
        }
        needUpdate = true
    }
    
    func deleteItem(indexSet: IndexSet) {
        for index in indexSet {
            todosVM.removeTodoByIndex(index: index)
        }
        needUpdate = true
    }
    
    func deleteTodosDone() {
        todosVM.removeTodosDone()
        needUpdate = true
    }
}

struct ManualTodosList_Previews: PreviewProvider {
    static var previews: some View {
        ManualTodosList(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), selection: .constant(Set<UUID>()), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
    }
}
