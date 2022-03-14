//
//  AddListView.swift
//  Todolist
//
//  Created by Clément FLORET on 21/01/2022.
//

import SwiftUI

struct AddListView: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    
    @State var showAlert: Bool = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            AddListContent(showAlert: $showAlert)
                .alert("Error", isPresented: $showAlert) {
                    //actions
                } message: {
                    Text("The list could not be created")
                }
                .environmentObject(todoListsVM)

        } else {
            AddListContent(showAlert: $showAlert)
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"),
                          message: Text("The list could not be created"),
                          dismissButton: .cancel())
                }
                .environmentObject(todoListsVM)
        }
    }
}

struct AddListView_Previews: PreviewProvider {
    static var previews: some View {
        AddListView()
            .environmentObject(TodosVM())
            .environmentObject(TodoListsVM())
    }
}
