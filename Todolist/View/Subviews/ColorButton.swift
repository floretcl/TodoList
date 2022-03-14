//
//  ColorButton.swift
//  Todolist
//
//  Created by Clément FLORET on 13/01/2022.
//

import SwiftUI

struct ColorButton: View {
    @Binding var colorSelected: TodoListVM.ListColor
    
    let isSelected: Bool
    let color: Color
    
    var body: some View {
        Button {
            self.colorSelected =  self.color.toListColor
        } label: {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(color)
                .frame(width: 30, height: 30)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isSelected ? color : .clear, lineWidth: 2)
                )
        }
    }
}

struct ColorButton_Previews: PreviewProvider {
    static var previews: some View {
        ColorButton(
            colorSelected: .constant(.purple),
            isSelected: false,
            color: .purple)
            .previewLayout(.sizeThatFits)
    }
}
