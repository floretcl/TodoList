//
//  AddViewContent.swift
//  Todolist
//
//  Created by Clément FLORET on 23/12/2021.
//

import SwiftUI

struct AddTodoContent: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var showAlert: Bool
    
    var list: TodoListVM?
    
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM
    
    @State private var todoNotification: TodoNotificationVM? = nil
    
    @State private var todoNameAlreadyExist: Bool = false
    @State private var showTodoDatePicker: Bool = false
    
    @State private var todoVM: TodoVM? = nil
    @State private var todoName: String = "Todo Name"
    @State private var todoListSelection: String = "Todo"
    @State private var todoListVM: TodoListVM? = nil
    @State private var todoPriority: TodoVM.TodoPriority = .medium
    @State private var todoDate: Date = Date()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TodoCellPreview(name: todoName, iconName: todoListVM?.image.name, color: todoListVM?.color.toColor())
                } header: {
                    Text("Preview")
                }
                Section {
                    HStack {
                        if #available(iOS 14.2, *) {
                            Image(systemName: "character.book.closed")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        } else {
                            Image(systemName: "a.book.closed")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                        }
                        Text("Name :")
                        Spacer()
                        TextEditor(text: $todoName)
                            .multilineTextAlignment(.leading)
                            .onChange(of: todoName) { _ in
                                todoNameAlreadyExist = todosVM.todoNameAlreadyExist(name: todoName)
                            }
                    }.padding(.vertical, 8)
                    if todoNameAlreadyExist {
                        HStack {
                            Text("A todo already exist with this name")
                                .font(.callout)
                                .foregroundColor(.red)
                        }
                    }
                    if #available(iOS 15.0, *) {
                        HStack {
                            Picker(
                                selection: $todoListSelection,
                                label: HStack {
                                    Image(systemName: "list.number")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                    Text("List :")
                                }
                            ) {
                                ForEach(todoListsVM.lists) { list in
                                    Text(list.name)
                                        .tag(list.name)
                                }
                            }
                            .onAppear(perform: {
                                    self.updateList()
                            })
                            .onChange(of: todoListSelection) { listName in
                                    self.updateList()
                            }
                        }.padding(.vertical, 10)
                    } else {
                        HStack {
                            Picker(
                                selection: $todoListSelection,
                                label: HStack {
                                    Image(systemName: "list.number")
                                        .font(.title2)
                                        .foregroundColor(.accentColor)
                                    Text("List :")
                                }
                            ) {
                                ForEach(todoListsVM.lists) { list in
                                    Text(list.name)
                                        .tag(list.name)
                                }
                            }
                            .onAppear(perform: {
                                    self.updateList()
                            })
                            .onChange(of: todoListSelection) { listName in
                                    self.updateList()
                            }
                        }.padding(.vertical, 10)
                    }
                    if #available(iOS 15.0, *) {
                        HStack {
                            Picker(
                                selection: $todoPriority,
                                label:
                                    HStack {
                                        Image(systemName: "flag")
                                            .font(.title2)
                                            .foregroundColor(.accentColor)
                                        Text("Priority :")
                                    }
                                    
                            ) {
                                ForEach(TodoVM.TodoPriority.allCases.indices) { index in
                                    Text(TodoVM.TodoPriority.allCases[index].name).tag(TodoVM.TodoPriority.allCases[index])
                                }
                            }
                        }.padding(.vertical, 10)
                    } else {
                        HStack {
                            Picker(
                                selection: $todoPriority,
                                label:
                                    HStack {
                                        Image(systemName: "flag")
                                            .font(.title2)
                                            .foregroundColor(.accentColor)
                                        Text("Priority :")
                                    }
                                    
                            ) {
                                ForEach(TodoVM.TodoPriority.allCases.indices) { index in
                                    Text(TodoVM.TodoPriority.allCases[index].name).tag(TodoVM.TodoPriority.allCases[index])
                                }
                            }
                        }.padding(.vertical, 10)
                    }
                    Toggle(isOn: $showTodoDatePicker) {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("Date")
                    }
                    .padding(.vertical, 5)
                    if showTodoDatePicker {
                        HStack {
                            DatePicker(selection: $todoDate, displayedComponents: [.hourAndMinute, .date]) {}
                            .datePickerStyle(GraphicalDatePickerStyle())
                        }.padding(.vertical, 10)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Add a Todo"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.addTodo()
                        self.resetState()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Add")
                            .foregroundColor(Color.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(todoName.isBlank ? Color.gray : Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                    }.disabled(todoName.isBlank)
                }
            }.onAppear {
                if list != nil {
                    todoListSelection = list!.name
                } else {
                    todoListSelection = todoListsVM.lists[0].name
                }
            }
        }
    }
    
    func updateList() {
        for list in todoListsVM.lists {
            if list.name == todoListSelection {
                self.todoListVM = list
            }
        }
    }
    
    func addTodo() {
        if todoListVM != nil {
            
            // Create a TodoVM
            self.todoVM = TodoVM(
                name: todoName,
                dateAdded: Date(),
                dateTodo: showTodoDatePicker ? todoDate : nil,
                priority: todoPriority,
                list: todoListVM!,
                index: 0)
            guard let todoVM = todoVM else { return }
            
            // Add Todo to CoreData
            guard let list = todoListsVM.getTodoList(todoListVM: todoListVM!) else { return }
            self.todosVM.addTodo(todoVM: todoVM, todoList: list)
            
            // Add Notification if necessary
            if showTodoDatePicker && todoVM.notificationIdentifier != "" {
                
                // Create TodoNotificationVM
                self.todoNotification = TodoNotificationVM(title: "Don't Forget", subtitle: todoName, date: todoDate)
                guard let notification = todoNotification else { return }
                
                // Add notification to NotificationCenter
                todoNotificationsManagerVM.addNotification(notification: notification)
            }
        } else {
            showAlert.toggle()
        }
    }
    
    func resetState() {
        self.todoVM = nil
    }
}

struct AddTodoContent_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoContent(showAlert: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodoListsVM())
            .environmentObject(TodosVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
