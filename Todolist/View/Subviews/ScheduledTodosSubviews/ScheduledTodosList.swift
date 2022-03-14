//
//  ScheduledTodosList.swift
//  Todolist
//
//  Created by Clément FLORET on 13/02/2022.
//

import SwiftUI

struct ScheduledTodosList: View {
    @EnvironmentObject var todosVM: TodosVM
    
    @AppStorage var showTodosDone: Bool
    
    @Binding var selection: Set<UUID>
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    private var numberOfDone: Int {
        return todosVM.getTodosDoneWithDateReminderCount()
    }
    private var todos: [TodoVM] {
        return todosVM.todosScheduled().sorted(by: {
            $0.dateTodo! > $1.dateTodo!
        })
    }
    private var todosNotDone: [TodoVM] {
        return todosVM.todosNotDoneAndScheduled().sorted(by: {
            $0.dateTodo! > $1.dateTodo!
        })
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        
        // Set Date/Time Style
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        // Set Locale
        dateFormatter.locale = .current
        
        return dateFormatter
    }
    
    var body: some View {
        VStack {
            if todosVM.todos.count != 0 {
                if showTodosDone {
                    List(selection: $selection) {
                        Section {
                            if todos.count != 0 {
                                ForEach(todos) { todo in
                                    VStack(alignment: .leading) {
                                        Text("Date : \(dateFormatter.string(from: todo.dateTodo ?? Date() ))")
                                            .font(.callout)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 2)
                                        TodoCell(
                                            todoVM: todo,
                                            withIcon: true,
                                            needUpdate: $needUpdate,
                                            editMode: $editMode)
                                    }
                                }
                                .onDelete { indexSet in
                                    self.deleteItem(list: todos, indexSet: indexSet)
                                }
                            } else {
                                Text("No Todos found")
                                    .padding(20)
                            }
                        } header: {
                            HStack {
                                Text("\(numberOfDone) Done -")
                                Button {
                                    self.deleteTodosDone(list: todos)
                                } label: {
                                    Text("Delete")
                                        .foregroundColor(.accentColor)
                                        .disabled(todosVM.getTodosDoneCount(list: todosVM.todosScheduled()) == 0 ? true : false)
                                }
                            }
                        }
                    }
                } else {
                    List(selection: $selection) {
                        if todosNotDone.count != 0 {
                            ForEach(todosNotDone) { todo in
                                VStack(alignment: .leading) {
                                    Text("Date : \(dateFormatter.string(from: todo.dateTodo ?? Date() ))")
                                        .font(.callout)
                                        .fontWeight(.medium)
                                        .padding(.vertical, 2)
                                    TodoCell(
                                        todoVM: todo,
                                        withIcon: true,
                                        needUpdate: $needUpdate,
                                        editMode: $editMode)
                                }
                            }
                            .onDelete { indexSet in
                                self.deleteItem(list: todosNotDone, indexSet: indexSet)
                            }
                        } else {
                            Text("No Todos found")
                                .padding(20)
                        }
                    }
                }
            } else {
                Text("No Todos found")
                    .padding(20)
                Spacer()
            }
        }
        .onAppear {
            needUpdate = true
        }
        .listStyle(.insetGrouped)
    }
    
    func deleteItem(list: [TodoVM], indexSet: IndexSet) {
        for index in indexSet {
            todosVM.removeTodoByList(list: list, index: index)
        }
        needUpdate = true
    }
    
    func deleteTodosDone(list: [TodoVM]) {
        todosVM.removeTodosDoneByList(list: list)
        needUpdate = true
    }
}

struct ScheduledTodosList_Previews: PreviewProvider {
    static var previews: some View {
        ScheduledTodosList(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), selection: .constant(Set<UUID>()), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
    }
}
