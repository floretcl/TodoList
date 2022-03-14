//
//  ByListTodosList.swift
//  Todolist
//
//  Created by Clément FLORET on 31/01/2022.
//

import SwiftUI

struct ByListTodosList: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todosVM: TodosVM
    
    @AppStorage var showTodosDone: Bool
    
    @Binding var selection: Set<UUID>
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    var body: some View {
        VStack {
            if todoListsVM.lists.count != 0 {
                List(selection: $selection) {
                    ForEach(todoListsVM.lists) { list in
                        Section {
                            if showTodosDone {
                                if list.todos.count != 0 {
                                    ForEach(list.todos.sorted(by: {
                                        $0.index < $1.index
                                    })) { todo in
                                        TodoCell(
                                            todoVM: todo,
                                            withIcon: false,
                                            needUpdate: $needUpdate,
                                            editMode: $editMode)
                                            .onChange(of: todo.done) { _ in
                                                needUpdate = true
                                            }
                                    }
                                    .onMove(perform: { indexSet, index in
                                        self.moveItem(indexSet: indexSet, destination: index, list: list.todos.sorted(by: {
                                            $0.index < $1.index
                                        }))
                                    })
                                    .onDelete { indexSet in
                                        self.deleteItem(list: list.todos.sorted(by: {
                                            $0.index < $1.index
                                        }), indexSet: indexSet)
                                    }
                                } else {
                                    Text("No Todos found")
                                        .padding(20)
                                }
                            } else {
                                if todosWithoutDone(list: list).count != 0 {
                                    ForEach(todosWithoutDone(list: list).sorted(by: {
                                        $0.index < $1.index
                                    })) { todo in
                                        TodoCell(
                                            todoVM: todo,
                                            withIcon: false,
                                            needUpdate: $needUpdate,
                                            editMode: $editMode)
                                            .onChange(of: todo.done) { _ in
                                                needUpdate = true
                                            }
                                    }
                                    .onMove(perform: { indexSet, index in
                                        self.moveItem(indexSet: indexSet, destination: index, list: todosWithoutDone(list: list).sorted(by: {
                                            $0.index < $1.index
                                        }))
                                    })
                                    .onDelete { indexSet in
                                        self.deleteItem(list: todosWithoutDone(list: list).sorted(by: {
                                            $0.index < $1.index
                                        }), indexSet: indexSet)
                                    }
                                } else {
                                    Text("No Todos found")
                                        .padding(20)
                                }
                            }
                        } header: {
                            Label(list.name, systemImage: list.image.name)
                                .foregroundColor(list.color.toColor())
                        }
                    }
                }
            } else {
                Text("No Lists found")
                    .padding(20)
                Spacer()
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

struct ByListTodosList_Previews: PreviewProvider {
    static var previews: some View {
        ByListTodosList(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), selection: .constant(Set<UUID>()), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodoListsVM())
            .environmentObject(TodosVM())
    }
}
