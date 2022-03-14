//
//  TodoCellPreview.swift
//  Todolist
//
//  Created by Clément FLORET on 21/01/2022.
//

import SwiftUI

struct TodoCellPreview: View {
    var name: String
    var iconName: String?
    var color: Color?
    
    var body: some View {
        HStack {
            Image(systemName: iconName ?? "list.bullet")
                .font(.title2)
                .foregroundColor(color ?? .primary)
            Text(name)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "circle")
                .font(.title2)
                .foregroundColor(color ?? .primary)
        }
    }
}

struct TodoCellPreview_Previews: PreviewProvider {
    static var previews: some View {
        TodoCellPreview(name: "Preview Todo")
            .previewLayout(.sizeThatFits)
    }
}
