//
//  TodoCell.swift
//  Todolist
//
//  Created by Clément FLORET on 06/01/2022.
//

import SwiftUI

struct TodoCell: View {
    @EnvironmentObject var todosVM: TodosVM
    @EnvironmentObject var todoListsVM: TodoListsVM
    @EnvironmentObject var todoNotificationsManagerVM : TodoNotificationsManagerVM

    var todoVM: TodoVM
    @State var withIcon: Bool
    private var color: Color {
        return todoVM.list.color.toColor()
    }
    private var iconName: String {
        return todoVM.list.image.name
    }
    @State var text: String = ""
    
    @State var showDetailView: Bool = false
    @Binding var needUpdate: Bool
    @Binding var editMode: EditMode
    
    var body: some View {
        HStack {
            HStack {
                if withIcon {
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 35, height: 35, alignment: .center)
                }
                Text(todoVM.name)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if editMode == .inactive {
                Button {
                    self.setToDone()
                } label: {
                    Image(systemName: todoVM.done ? "checkmark.circle" : "circle")
                        .font(.title2)
                        .foregroundColor(color)
                }
            } else {
                Button {
                    showDetailView.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)
                }

            }
        }
        .contextMenu(menuItems: {
            Button("Edit") {
                showDetailView.toggle()
            }
            Button(todoVM.done ? "Un done": "Done") {
                self.setToDone()
            }
        })
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetailView, onDismiss: {
            needUpdate = true
        }, content: {
            TodoDetailView(todoVM: todoVM)
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
        })
    }
    
    func setToDone() {
        todoVM.done.toggle()
        todosVM.setTodoDone(todoVM: todoVM, isDone: todoVM.done)
        needUpdate = true
    }
}

struct TodoCell_Previews: PreviewProvider {
    static var previews: some View {
        TodoCell(
            todoVM: TodoVM(
                name: "New Task",
                dateAdded: Date(),
                dateTodo: nil,
                priority: .medium,
                list: TodoListVM(name: "New Task",
                                 image: .list,
                                 color: .blue,
                                 dateAdded: Date(),
                                 index: 0),
                index: 0),
            withIcon: true,
            needUpdate: .constant(false),
            editMode: .constant(.inactive))
            .environmentObject(TodosVM())
            .environmentObject(TodoListsVM())
            .environmentObject(TodoNotificationsManagerVM())
            .previewLayout(.sizeThatFits)
        
    }
}
