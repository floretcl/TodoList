//
//  TodosListToolbar.swift
//  Todolist
//
//  Created by Clément FLORET on 13/02/2022.
//

import Foundation
import SwiftUI

struct TodosListToolbar: ToolbarContent {
    @EnvironmentObject var todosVM: TodosVM
    
    @AppStorage var showTodosDone: Bool
    
    var selection: Set<UUID>
    var toSetDone: Bool
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    @Binding var showAddView: Bool
    
    let setDoneSelected: () -> Void
    let deleteSelected: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if editMode == .inactive {
                Menu(content: {
                    AddButton(text: "Add Todo", editMode: $editMode, showAddView: $showAddView)
                    ShowDoneButton(showTodosDone: _showTodosDone, needUpdate: $needUpdate)
                    EditButton()
                }, label: {
                    if #available(iOS 15.0, *) {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.accentColor)
                    } else {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                })
            } else {
                EditButton()
            }
        }
        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                setDoneSelected()
            } label: {
                Image(systemName: toSetDone ? "checkmark.circle" : "circle")
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 5)
                    .disabled(selection == [])
            }
            Spacer()
            Button {
                deleteSelected()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.accentColor)
                    .padding(.bottom, 5)
                    .disabled(selection == [])
            }
        }
    }
}
