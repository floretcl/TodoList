//
//  TodoListView.swift
//  Dontforget
//
//  Created by Clément FLORET on 31/01/2022.
//

import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var todosVM: TodosVM
    var showTodosDone: Bool
    @Binding var editMode: EditMode
    @State var selection = Set<UUID>()
    @Binding var needUpdate: Bool
    private var numberOfDone: Int {
        return todosVM.getTodosCount()
    }
    
    var body: some View {
        if todosVM.todos.count != 0 {
            if showTodosDone {
                List(selection: $selection) {
                    Section {
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
                    } header: {
                        HStack {
                            Text("\(numberOfDone) Done -")
                            Button {
                                
                            } label: {
                                Text("Delete")
                            }
                        }
                    }
                }
                .onAppear {
                    needUpdate = true
                }
            } else {
                List(selection: $selection) {
                    ForEach(todosVM.getNotDone()) { todo in
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
                }
                .onAppear {
                    needUpdate = true
                }
            }
        } else {
            Text("No Todos found")
                .padding(20)
        }
    }
    
    func moveItem(indexSet: IndexSet, destination: Int) {
        // Change the order of todolist for view
        // self.todosVM.todos.move(fromOffsets: indexSet, toOffset: destination)
        
        // Change order of todolist in coreData
        for index in indexSet {
            todosVM.moveTodo(index: index, destination: destination)
        }
        needUpdate = true
    }
    
    func deleteItem(indexSet: IndexSet) {
        for index in indexSet {
            todosVM.removeTodo(index: index)
        }
        needUpdate = true
    }
}

struct TodoListView_Previews: PreviewProvider {
    static var previews: some View {
        TodoListView(showTodosDone: true, editMode: .constant(.inactive), needUpdate: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
    }
}
