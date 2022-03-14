//
//  TodoListCell.swift
//  Todolist
//
//  Created by Clément FLORET on 27/12/2021.
//

import SwiftUI

struct TodoListCell: View {
    @EnvironmentObject var todoListsVM: TodoListsVM
    
    var list: TodoListVM
    
    @State var showDetailView: Bool = false
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    private var color: Color {
        return list.color.toColor()
    }
    private var todosNotDoneCount: Int {
        return list.getTodosNotDone().count
    }
    
    var body: some View {
        HStack {
            Image(systemName: list.image.name)
                .font(.headline)
                .foregroundColor(.white)
                .padding(8)
                .background(
                    Circle()
                        .foregroundColor(color)
                        .frame(width: 32, height: 32, alignment: .center)
                )
                .frame(width: 40, height: 40, alignment: .center)
            Text(list.name)
                .fontWeight(.bold)
                .multilineTextAlignment(.leading)
                .foregroundColor(color)
            Spacer()
            if editMode == .inactive {
                Text("\(todosNotDoneCount)")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            } else {
                Button {
                    showDetailView.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailView, onDismiss: {
            needUpdate = true
        }, content: {
            ListDetailView(listVM: list)
                .environmentObject(todoListsVM)
        })
    }
}

struct TodoListCell_Previews: PreviewProvider {
    static var previews: some View {
        TodoListCell(list: TodoListVM(name: "Tasks", image: .list, color: .gray, dateAdded: Date(), index: 0), needUpdate: .constant(false), editMode: .constant(.inactive))
            .environmentObject(TodoListsVM())
            .previewLayout(.sizeThatFits)
    }
}
