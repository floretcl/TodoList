//
//  AddTodoView.swift
//  Todolist
//
//  Created by Clément FLORET on 21/01/2022.
//

import SwiftUI

struct AddTodoView: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM
    
    @State var showAlert: Bool = false
    
    var list: TodoListVM?
    
    var body: some View {
        if #available(iOS 15.0, *) {
            AddTodoContent(showAlert: $showAlert, list: list)
                .alert("Error", isPresented: $showAlert) {
                    //actions
                } message: {
                    Text("The todo could not be created")
                }
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        } else {
            AddTodoContent(showAlert: $showAlert, list: list)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text("The todo could not be created"),
                          dismissButton: .cancel())
                }
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        }
    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView()
            .environmentObject(TodoListsVM())
            .environmentObject(TodosVM())
            .environmentObject(TodoNotificationsManagerVM())
    }
}
