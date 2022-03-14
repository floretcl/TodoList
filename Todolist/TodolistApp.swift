//
//  TodolistApp.swift
//  Todolist
//
//  Created by Clément FLORET on 14/12/2021.
//

import SwiftUI

@main
struct TodolistApp: App {
    let persistenceController = PersistenceController.shared
    let viewContext = PersistenceController.shared.container.viewContext
    
    @StateObject var todosVM = TodosVM()
    @StateObject var todoListsVM = TodoListsVM()
    @StateObject var todoNotificationsManagerVM = TodoNotificationsManagerVM()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(todosVM)
                .environmentObject(todoListsVM)
                .environmentObject(todoNotificationsManagerVM)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        }
    }
}
