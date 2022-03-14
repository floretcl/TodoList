//
//  AddListButton.swift
//  Todolist
//
//  Created by Clément FLORET on 27/12/2021.
//

import SwiftUI

struct AddButton: View {
    var text: String
    
    @Binding var editMode: EditMode
    @Binding var showAddView: Bool
    
    var body: some View {
        Button {
            editMode = .inactive
            showAddView.toggle()
        } label: {
            HStack(spacing: 0) {
                if #available(iOS 15.0, *) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding(2)
                        .background(
                            Circle()
                                .foregroundColor(.accentColor))
                    Text(text)
                        .foregroundColor(.accentColor)
                        .font(.headline)
                        .padding(.horizontal, 8)
                } else {
                    Text("Add \(text)")
                }
            }.padding(.horizontal, 10)
        }
    }
}

struct AddButton_Previews: PreviewProvider {
    static var previews: some View {
        AddButton(text: "Todo", editMode: .constant(.inactive), showAddView: .constant(false))
            .previewLayout(.sizeThatFits)
    }
}
