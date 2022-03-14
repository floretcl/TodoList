//
//  IconButton.swift
//  Todolist
//
//  Created by Clément FLORET on 14/01/2022.
//

import SwiftUI

struct IconButton: View {
    @Binding var iconSelected: TodoListVM.ListImage
    
    let iconName: String
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        Button {
            self.iconSelected = TodoListVM.ListImage(rawValue: iconName) ?? TodoListVM.ListImage.list
        } label: {
            Image(systemName: iconName)
                .foregroundColor(.primary)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected ? color : .clear, lineWidth: 2)
                )
        }
    }
}

struct IconButton_Previews: PreviewProvider {
    static var previews: some View {
        IconButton(iconSelected: .constant(.list), iconName: "list.bullet", isSelected: false, color: Color.gray)
            .previewLayout(.sizeThatFits)
    }
}
