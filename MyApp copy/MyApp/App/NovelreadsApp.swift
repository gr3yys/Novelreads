//
//  MyAppApp.swift
//  MyApp
//
//  Created by greys on 10/6/24.
//

import SwiftUI
import Firebase

@main
struct NovelreadsApp: App {
    @StateObject var viewModel = AuthViewModel()
    @StateObject private var bookManager = BookManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(bookManager)
        }
    }
}
