//
//  AddListContent.swift
//  Todolist
//
//  Created by Clément FLORET on 29/12/2021.
//

import SwiftUI

struct AddListContent: View {
    @Environment(\.presentationMode) var presentation
    
    @Binding var showAlert: Bool
    
    @EnvironmentObject var todoListsVM: TodoListsVM
    
    @State private var listVM: TodoListVM? = nil
    @State private var listName: String = "My Todo list"
    @State private var listColor: TodoListVM.ListColor = .blue
    @State private var listImage: TodoListVM.ListImage = .list
    @State private var listOrder: Int = 0
    @State private var listNameAlreadyExist: Bool = false
    
    var colorsColumns = GridItem(.flexible(minimum: 34, maximum: 50))
    var colorsNbColumns: Int = TodoListVM.ListColor.count/2
    var colorsColumnsSpacing: CGFloat = 10
    var iconsColumns = GridItem(.flexible(minimum: 42, maximum: 60))
    var iconsNbColumns: Int = 5
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TodoListCellPreview(name: listName, iconName: listImage.name, color: listColor.toColor())
                        .padding(.vertical, 4)
                } header: {
                    Text("Preview")
                }
                Section {
                    HStack {
                        Text("Name :")
                        Spacer()
                        TextEditor(text: $listName)
                            .multilineTextAlignment(.leading)
                            .onChange(of: listName) { _ in
                                listNameAlreadyExist = todoListsVM.listNameAlreadyExist(name: listName)
                            }
                    }.padding(.vertical, 12)
                    if listNameAlreadyExist {
                        HStack {
                            Text("A list already exist with this name")
                                .font(.callout)
                                .foregroundColor(.red)
                        }
                    }
                    VStack {
                        if #available(iOS 15.0, *) {
                            HStack {
                                Text("Color: ")
                            }
                            HStack {
                                Picker("", selection: $listColor) {
                                    LazyVGrid(
                                        columns: Array(repeating: colorsColumns, count: colorsNbColumns),
                                        spacing: colorsColumnsSpacing) {
                                            ForEach(TodoListVM.ListColor.allCases) { color in
                                            ColorButton(
                                                colorSelected: $listColor,
                                                isSelected: listColor == color ? true : false,
                                                color: color.toColor())
                                                .animation(.easeInOut, value: listColor)
                                        }
                                    }
                                }.pickerStyle(.inline)
                            }
                        } else {
                            HStack {
                                Picker("Color", selection: $listColor) {
                                    LazyVGrid(
                                        columns: Array(repeating: colorsColumns, count: colorsNbColumns),
                                        spacing: colorsColumnsSpacing) {
                                        ForEach(TodoListVM.ListColor.allCases) { color in
                                            if color != .brown && color != .cyan && color != .indigo && color != .mint {
                                                ColorButton(
                                                    colorSelected: $listColor,
                                                    isSelected: listColor == color ? true : false,
                                                    color: color.toColor())
                                                    .animation(.easeInOut, value: listColor)
                                            }
                                        }
                                    }
                                }
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(listColor.toColor())
                                    .frame(width: 30, height: 30)
                                    .padding(4)
                            }
                        }
                    }.padding(.vertical, 10)
                    VStack {
                        if #available(iOS 15.0, *) {
                            HStack {
                                Text("Icon: ")
                            }
                            Picker("", selection: $listImage) {
                                LazyVGrid(
                                    columns: Array(repeating: iconsColumns, count: iconsNbColumns),
                                    spacing: 0) {
                                    ForEach(TodoListVM.ListImage.allCases) { icon in
                                        IconButton(
                                            iconSelected: $listImage,
                                            iconName: icon.name,
                                            isSelected: listImage == icon ? true : false,
                                            color: listColor.toColor())
                                            .font(.title2)
                                            .animation(.easeInOut, value: listImage)
                                    }
                                }
                            }.pickerStyle(.inline)
                        } else {
                            HStack {
                                Picker("Icon", selection: $listImage) {
                                    LazyVGrid(
                                        columns: Array(repeating: iconsColumns, count: iconsNbColumns),
                                        spacing: 0) {
                                        ForEach(TodoListVM.ListImage.allCases) { icon in
                                            IconButton(
                                                iconSelected: $listImage,
                                                iconName: icon.name,
                                                isSelected: listImage == icon ? true : false,
                                                color: listColor.toColor())
                                                .font(.title2)
                                                .animation(.easeInOut, value: listImage)
                                        }
                                    }
                                }
                                Image(systemName: listImage.name)
                                    .font(.title2)
                                    .frame(width: 30, height: 30)
                                    .padding(4)
                            }
                            
                        }
                    }.padding(.vertical, 10)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle(Text("Add a List"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        self.addList()
                        self.resetState()
                        presentation.wrappedValue.dismiss()
                    } label: {
                        Text("Add")
                            .foregroundColor(Color.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 15)
                            .background(listName.isBlank ? Color.gray : .accentColor)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                    }.disabled(listName.isBlank || listNameAlreadyExist)
                }
            }
        }
    }
    
    func addList() {
        self.listVM = TodoListVM(
            name: listName,
            image: listImage,
            color: listColor,
            dateAdded: Date(),
            index: 0)
        if listVM != nil {
            todoListsVM.addList(listVM: listVM!)
        } else {
            showAlert.toggle()
        }
    }
    
    func resetState() {
        self.listVM = nil
    }
}

struct AddListContent_Previews: PreviewProvider {
    static var previews: some View {
        AddListContent(showAlert: .constant(false))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(TodoListsVM())
    }
}
