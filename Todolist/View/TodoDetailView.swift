//
//  TodoDetailView.swift
//  Todolist
//
//  Created by Clément FLORET on 19/01/2022.
//

import SwiftUI

struct TodoDetailView: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM
    
    @State var showAlert: Bool = false
    
    var todoVM: TodoVM
    
    var body: some View {
        if #available(iOS 15.0, *) {
            TodoDetailContent(showAlert: $showAlert, todoVM: todoVM)
                .alert("Error", isPresented: $showAlert) {
                    //actions
                } message: {
                    Text("The todo could not be modified")
                }
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        } else {
            TodoDetailContent(showAlert: $showAlert, todoVM: todoVM)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text("The todo could not be modified"),
                          dismissButton: .cancel())
                }
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        }
    }
}

struct TodoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TodoDetailView(todoVM: TodoVM(
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
            .environmentObject(TodoListsVM())
            .environmentObject(TodosVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
