//
//  TodoDetailContent.swift
//  Todolist
//
//  Created by Clément FLORET on 25/02/2022.
//

import SwiftUI

struct TodoDetailContent: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var showAlert: Bool
    
    var todoVM: TodoVM
    
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM
    
    @State private var todoNotification: TodoNotificationVM? = nil

    @State private var todoNameAlreadyExist: Bool = false
    @State private var showTodoDatePicker: Bool = false
    
    @State private var todoName: String = "Todo Name"
    @State private var todoListSelection: String = "Todo"
    @State private var todoListVM: TodoListVM? = nil
    @State private var todoPriority: TodoVM.TodoPriority = .medium
    @State private var todoDate: Date = Date()
    @State private var todoIsDone: Bool = false
    
    private var notModified: Bool {
        if todoName == todoVM.name
            && todoListSelection == todoVM.list.name
            && todoPriority == todoVM.priority
            && todoDate == todoVM.dateTodo
            && todoIsDone == todoVM.done {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            List {
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
                                ForEach(TodoVM.TodoPriority.allCases, id: \.self) { priority in
                                    Text(priority.name).tag(priority)
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
                                ForEach(TodoVM.TodoPriority.allCases, id: \.self) { priority in
                                    Text(priority.name).tag(priority)
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
                    Toggle(isOn: $todoIsDone) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        Text("Is Done")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Todo Detail"))
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
                        self.modifyTodo()
                        self.resetState()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Ok")
                            .foregroundColor(Color.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(todoName.isBlank ? Color.gray : Color.accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                    }.disabled(todoName.isBlank || notModified)
                }
            }
        }.onAppear {
            self.todoName = todoVM.name
            self.todoListSelection = todoVM.list.name
            self.todoPriority = todoVM.priority
            self.todoDate = todoVM.dateTodo ?? Date()
            self.showTodoDatePicker = todoVM.dateTodo != nil ? true : false
            self.todoIsDone = todoVM.done
        }
    }
    
    func updateList() {
        for list in todoListsVM.lists {
            if list.name == todoListSelection {
                self.todoListVM = list
            }
        }
    }

    func modifyTodo() {
        if todoListVM != nil {
            
            // Modify Todo to CoreData
            guard let list = todoListsVM.getTodoList(todoListVM: todoListVM!) else { return }
            self.todosVM.modifyTodo(todoVM: todoVM, name: todoName, dateTodo: showTodoDatePicker ? todoDate : nil, priority: todoPriority, todoList: list, done: todoIsDone)

            // Remove and add a new TodoNotification if necessary
            if showTodoDatePicker && todoVM.notificationIdentifier != "" {
                // Remove Old TodoNotification
                todoNotificationsManagerVM.removeNotification(identifier: todoVM.notificationIdentifier)
                // Create TodoNotification
                self.todoNotification = TodoNotificationVM(title: "Don't Forget", subtitle: todoName, date: todoDate)
                // Add notification to NotificationCenter
                todoNotificationsManagerVM.addNotification(notification: todoNotification!)
            }
        } else {
            showAlert.toggle()
        }
    }

    func resetState() {
        self.todoName = "Todo Name"
        self.todoListSelection = "Todo"
        self.todoPriority = .medium
        self.todoDate = Date()
        self.todoListVM = nil
        self.todoIsDone = false
        
        self.showTodoDatePicker = false
        self.todoDate = Date()
    }
}

struct TodoDetailContent_Previews: PreviewProvider {
    static var previews: some View {
        TodoDetailContent(
            showAlert: .constant(false),
            todoVM: TodoVM(
                name: "Todo",
                dateAdded: Date(),
                dateTodo: nil,
                priority: .medium,
                list: TodoListVM(
                    name: "TodoList",
                    image: .list,
                    color: .red,
                    dateAdded: Date(),
                    index: 0),
                index: 0))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodoListsVM())
            .environmentObject(TodosVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
