//
//  SearchBarList.swift
//  Todolist
//
//  Created by Clément FLORET on 29/01/2022.
//

import SwiftUI

struct SearchBarList: View {
    @EnvironmentObject var todosVM: TodosVM
    
    @Binding var searchBarText: String
    @State var needUpdate: Bool = false
    @Binding var editMode: EditMode
    
    var body: some View {
        List {
            Section {
                ForEach(todosVM.todos) { todo in
                    TodoCell(
                        todoVM: todo,
                        withIcon: true,
                        needUpdate: $needUpdate,
                        editMode: $editMode)
                        .environmentObject(todosVM)
                }
                .onDelete { indexSet in
                    self.deleteItem(indexSet: indexSet)
                }
                .onChange(of: searchBarText) { text in
                    self.updateSearch(text: text)
                }
                .onChange(of: needUpdate) { _ in
                    self.updateSearch(text: searchBarText)
                }
                .onAppear(perform: {
                    self.updateSearch(text: searchBarText)
                })
            }
        }
    }
    
    func deleteItem(indexSet: IndexSet) {
        for index in indexSet {
            todosVM.removeTodoByIndex(index: index)
        }
        updateSearch(text: searchBarText)
    }
    
    func updateSearch(text: String) {
        todosVM.fetchTodosOfSearchByName(predicateString: text, ascending: true)
        needUpdate = false
    }
}
