//
// SettingsView.swift
//  MyApp
//
//  Created by greys on 10/6/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingLoginView = false

    var body: some View {
        VStack {
            if let user = viewModel.currentUser {
                List {
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.gray)
                                .clipShape(Circle())
                                .padding()

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.username)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.top, 4)

                                Text(user.email)
                                    .font(.footnote)
                                    .accentColor(.gray)
                            }
                        }
                    }
                    
                    Section("General") {
                        HStack {
                            SettingsRowView(imageName: "gear",
                                            title: "Version",
                                            tintColor: Color(.systemGray))
                            
                            Spacer()
                            
                            Text("1.0.0")
                                .font(.subheadline)
                                .foregroundColor(Color(hex: "26344f"))
                                .accentColor(.gray)
                        }
                        .foregroundColor(Color(hex: "26344f"))
                    }
            
                    Section("Account") {
                        
                        // Change Name
                        NavigationLink(destination: ChangeNameView()) {
                            SettingsRowView(imageName: "", title: "Change Username", tintColor: Color(hex: "26344f"))
                        }
                        
                        // Reset password
                        NavigationLink(destination: ResetPasswordView()) {
                            SettingsRowView(imageName: "", title: "Reset Password", tintColor: Color(hex: "26344f"))
                        }
                        
                        // Information
                        NavigationLink(destination: InformationView()) {
                            SettingsRowView(imageName: "", title: "Information", tintColor: Color(hex: "26344f"))
                        }
                        
                        // Log out button
                        Button(action: {
                            viewModel.signOut()
                            showingLoginView = true // show LoginView
                        }) {
                            HStack {
                                Text("Log out")
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "26344f"))
                                Spacer()
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .foregroundColor(Color(.gray))
                            }
                            .padding(.horizontal, 8)
                        }

                        // Delete Button
                        Button(action: {
                            Task {
                                do {
                                    try await viewModel.deleteAccount()
                                    presentationMode.wrappedValue.dismiss()
                                } catch {
                                    // Handle the error
                                    print("Failed to delete account: \(error.localizedDescription)")
                                }
                            }
                        }) {
                            HStack {
                                Text("Delete Account")
                                    .font(.subheadline)
                                    .foregroundColor(Color(.red))
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(.red))
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .foregroundColor(Color(hex: "26344f"))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingLoginView) {
            LoginView() // Present LoginView when showingLoginView is true
        }
    }
}
