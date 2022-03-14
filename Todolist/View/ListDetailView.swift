//
//  ListDetailView.swift
//  Todolist
//
//  Created by Clément FLORET on 31/01/2022.
//

import SwiftUI

struct ListDetailView: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    
    @State var showAlert: Bool = false
    
    var listVM: TodoListVM
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ListDetailContent(showAlert: $showAlert, listVM: listVM)
                .alert("Error", isPresented: $showAlert) {
                    //actions
                } message: {
                    Text("The list could not be modified")
                }
                .environmentObject(todoListsVM)
        } else {
            ListDetailContent(showAlert: $showAlert, listVM: listVM)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text("The list could not be modified"),
                          dismissButton: .cancel())
                }
                .environmentObject(todoListsVM)
        }
    }
}

struct ListDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ListDetailView(
            listVM:
                TodoListVM(
                    name: "Todo List",
                    image: .list,
                    color: .gray,
                    dateAdded: Date(),
                    index: 0))
            .environmentObject(TodoListsVM())
    }
}
