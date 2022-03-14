//
//  TodoListCellPreview.swift
//  Todolist
//
//  Created by Clément FLORET on 21/01/2022.
//

import SwiftUI

struct TodoListCellPreview: View {
    var name: String
    var iconName: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .foregroundColor(color)
                )
            Text(name)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .foregroundColor(color)
            Spacer()
            Text("0")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TodoListCellPreview_Previews: PreviewProvider {
    static var previews: some View {
        TodoListCellPreview(name: "Preview List", iconName: "list.bullet", color: .gray)
            .previewLayout(.sizeThatFits)
    }
}
