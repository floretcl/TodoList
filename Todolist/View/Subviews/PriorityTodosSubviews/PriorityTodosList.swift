//
//  PriorityTodosList.swift
//  Todolist
//
//  Created by Clément FLORET on 14/02/2022.
//

import SwiftUI

struct PriorityTodosList: View {
    @EnvironmentObject var todosVM: TodosVM
    
    @AppStorage var showTodosDone: Bool
    
    @Binding var selection: Set<UUID>
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    var priorities: [String] = ["High", "Medium", "Low"]
    
    var body: some View {
        VStack {
            if todosVM.todos.count != 0 {
                List(selection: $selection) {
                    ForEach(priorities, id: \.self) { priority in
                        if todosVM.todosPriority(name: priority).count != 0 {
                            Section {
                                if showTodosDone {
                                    ForEach(todosVM.todosPriority(name: priority).sorted(by: {
                                        $0.index < $1.index
                                    })) { todo in
                                        TodoCell(
                                            todoVM: todo,
                                            withIcon: true,
                                            needUpdate: $needUpdate,
                                            editMode: $editMode)
                                            .onChange(of: todo.done) { _ in
                                                needUpdate = true
                                            }
                                    }
                                    .onMove(perform: { indexSet, index in
                                        self.moveItem(indexSet: indexSet, destination: index, list: todosVM.todosPriority(name: priority).sorted(by: {
                                            $0.index < $1.index
                                        }))
                                    })
                                    .onDelete { indexSet in
                                        self.deleteItem(list: todosVM.todosPriority(name: priority).sorted(by: {
                                            $0.index < $1.index
                                        }), indexSet: indexSet)
                                    }
                                } else {
                                    if todosVM.todosNotDoneAndPriority(name: priority).count != 0 {
                                        ForEach(todosVM.todosNotDoneAndPriority(name: priority).sorted(by: {
                                            $0.index < $1.index
                                        })) { todo in
                                            TodoCell(
                                                todoVM: todo,
                                                withIcon: true,
                                                needUpdate: $needUpdate,
                                                editMode: $editMode)
                                                .onChange(of: todo.done) { _ in
                                                    needUpdate = true
                                                }
                                        }
                                        .onMove(perform: { indexSet, index in
                                            self.moveItem(indexSet: indexSet, destination: index, list: todosVM.todosNotDoneAndPriority(name: priority).sorted(by: {
                                                $0.index < $1.index
                                            }))
                                        })
                                        .onDelete { indexSet in
                                            self.deleteItem(list: todosVM.todosNotDoneAndPriority(name: priority).sorted(by: {
                                                $0.index < $1.index
                                            }), indexSet: indexSet)
                                        }
                                    } else {
                                        Text("No Todos found")
                                            .padding(10)
                                    }
                                }
                            } header: {
                                Label(priority, systemImage: "flag")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            } else {
                Text("No Todos found")
                    .padding(20)
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
            todosVM.removeTodoByList(list: list, index: index)
        }
        needUpdate = true
    }
    
    func todosWithoutDone(list: TodoListVM) -> [TodoVM] {
        return list.todos.filter({ todo in
            todo.done == false
        })
    }
}

struct PriorityTodosList_Previews: PreviewProvider {
    static var previews: some View {
        PriorityTodosList(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), selection: .constant(Set<UUID>()), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
    }
}
