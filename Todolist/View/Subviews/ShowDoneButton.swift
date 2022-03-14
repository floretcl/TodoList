//
//  ShowDoneButton.swift
//  Todolist
//
//  Created by Clément FLORET on 06/02/2022.
//

import SwiftUI

struct ShowDoneButton: View {
    @AppStorage var showTodosDone: Bool
    @Binding var needUpdate: Bool
    
    var body: some View {
        Button {
            showTodosDone.toggle()
            needUpdate = true
        } label: {
            Label(showTodosDone ? "Hide todos done" : "Show todos done", systemImage: "eye")
                .foregroundColor(.accentColor)
        }
    }
}

struct ShowDoneButton_Previews: PreviewProvider {
    static var previews: some View {
        ShowDoneButton(showTodosDone: .init(wrappedValue: true, "show-todos-done", store: .standard), needUpdate: .constant(false))
    }
}
