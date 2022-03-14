//
//  AutoTodosListCell.swift
//  Todolist
//
//  Created by Clément FLORET on 12/01/2022.
//

import SwiftUI

struct AutoTodosListCell: View {
    var name: String
    var iconName: String
    var color: Color
    var todoCount: Int?
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.title2)
                .foregroundColor(color)
            Text(name)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .foregroundColor(.primary)
            Spacer()
            if let count = todoCount {
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
        }
    }
}

struct AutoTodosListCell_Previews: PreviewProvider {
    static var previews: some View {
        AutoTodosListCell(name: "Auto", iconName: "list.bullet", color: .gray, todoCount: 0)
            .previewLayout(.sizeThatFits)
    }
}
