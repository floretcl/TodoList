//
//  ContentView.swift
//  Todolist
//
//  Created by Clément FLORET on 14/12/2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM
    
    @AppStorage("show-todos-done") var showTodosDone: Bool = false
    
    @State var searchBarText: String = ""
    @State var isEditing: Bool = false
    @State var needUpdate: Bool = false
    @State var editMode: EditMode = .inactive
    
    @State var showAddView: Bool = false
    @State var showAddListView: Bool = false
    @State var showSettingsView: Bool = false
    
    private var todosNotDoneCount: Int {
        return todosVM.todosNotDone().count
    }
    private var todosNotDoneTodayCount: Int {
        return todosVM.todosNotDoneAndToday().count
    }
    private var todosNotDoneScheduledCount: Int {
        return todosVM.todosNotDoneAndScheduled().count
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchBarText: $searchBarText)
                if searchBarText.isBlank == false {
                    SearchBarList(
                        searchBarText: $searchBarText,
                        editMode: $editMode)
                        .onDisappear {
                            needUpdate = true
                        }
                } else {
                    Section {
                        List {
                            Section {
                                NavigationLink {
                                    AllTodosView()
                                        .onDisappear {
                                            needUpdate = true
                                        }
                                } label: {
                                    AutoTodosListCell(name: "All", iconName: "star.fill", color: .primary, todoCount: todosNotDoneCount)
                                }
                                NavigationLink {
                                    TodayTodosView()
                                        .onDisappear {
                                            needUpdate = true
                                        }
                                } label: {
                                    AutoTodosListCell(name: "Today", iconName: "calendar.badge.clock", color: .red, todoCount: todosNotDoneTodayCount)
                                }
                                NavigationLink {
                                    ScheduledTodosView()
                                        .onDisappear {
                                            needUpdate = true
                                        }
                                } label: {
                                    AutoTodosListCell(name: "Scheduled", iconName: "alarm", color: .orange, todoCount: todosNotDoneScheduledCount)
                                }
                                NavigationLink {
                                    PriorityTodosView()
                                        .onDisappear {
                                            needUpdate = true
                                        }
                                } label: {
                                    AutoTodosListCell(name: "Priority", iconName: "flag", color: .purple, todoCount: nil)
                                }
                            } header: {
                                Text("Automatic Lists")
                                    .font(.subheadline)
                            }
                            Section {
                                if todoListsVM.lists.count != 0 {
                                   ForEach(todoListsVM.lists) { list in
                                       NavigationLink {
                                           ListTodosView(list: list)
                                               .onDisappear {
                                                   needUpdate = true
                                               }
                                       } label: {
                                           TodoListCell(list: list, needUpdate: $needUpdate, editMode: $editMode)
                                       }
                                   }
                                   .onMove(perform: { indexSet, index in
                                       self.moveItem(indexSet: indexSet, destination: index)
                                   })
                                   .onDelete { index in
                                       self.deleteItem(indexSet: index)
                                       if todoListsVM.lists.count == 0 {
                                           self.createSamples()
                                           needUpdate = true
                                       }
                                   }
                                } else {
                                   Text("No Todo list found")
                                       .padding(30)
                                }
                            } header: {
                                Text("My Todo lists")
                                    .font(.subheadline)
                            }
                        }.listStyle(.insetGrouped)
                    }
                }
            }
            .padding(.bottom, 1)
            .navigationTitle("Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    AddButton(text: "Todo", editMode: $editMode, showAddView: $showAddView)
                        .sheet(isPresented: $showAddView, onDismiss: {
                            needUpdate = true
                        }, content: {
                            AddTodoView()
                                .environmentObject(todosVM)
                                .environmentObject(todoListsVM)
                                .environmentObject(todoNotificationsManagerVM)
                        })
                    Spacer()
                    AddButton(text: "List", editMode: $editMode, showAddView: $showAddListView)
                        .sheet(isPresented: $showAddListView, onDismiss: {
                            needUpdate = true
                        }, content: {
                            AddListView()
                                .environmentObject(todoListsVM)
                        })
                }
            }
            .environment(\.editMode, $editMode)
            .onAppear {
                self.update()
                if todoListsVM.lists.count == 0 {
                    self.createSamples()
                    self.update()
                }
            }
            .onChange(of: needUpdate) { _ in
                self.update()
            }
        }.navigationViewStyle(.stack)
    }
    
    func moveItem(indexSet: IndexSet, destination: Int) {
        // Change order of todolist in coreData
        for index in indexSet {
            todoListsVM.moveList(index: index, destination: destination)
        }
        self.update()
    }

    func createSamples() {
        // creation of sample list
        let sampleList = TodoListVM(
            name: "Todo",
            image: .list,
            color: .blue,
            dateAdded: Date(),
            index: 0)
        /// add sample list
        todoListsVM.addList(listVM: sampleList)
        
        self.update()
        
        // creation of sample todo
        let sampleTodo = TodoVM(
            name: "Hi, there is nothing here, add a todo now!",
            dateAdded: Date(),
            dateTodo: nil,
            priority: .medium,
            list: sampleList,
            index: 0)
        /// get sample list from CoreData
        guard let list = todoListsVM.getTodoList(todoListVM: sampleList) else { return }
        /// add sample todo
        todosVM.addTodo(todoVM: sampleTodo, todoList: list)
    }
    
    func deleteItem(indexSet: IndexSet) {
        for index in indexSet {
            todoListsVM.removeList(index: index)
        }
        self.update()
    }
    
    func update() {
        todoListsVM.fetchAllTodoListsByOrder(ascending: true)
        todosVM.fetchAllTodosByOrder(ascending: true)
        needUpdate = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodosVM())
            .environmentObject(TodoListsVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
