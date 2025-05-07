import SwiftUI

struct ContentView: View {
    @State private var isNavigatingToSignIn = false
    @State private var isNavigatingToLogin = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .frame(width: 140, height: 100)
                
                Text("Welcome to Novelreads")
                    .font(.title)
                    .fontWeight(.regular)
                    .foregroundColor(Color(hex: "26344f"))
                    .padding(.bottom, 10)

                Text("Create an account to get started on\n your next book reading journey.")
                    .foregroundColor(Color(hex: "26344f"))
                    .padding(.bottom, 24)
                    .multilineTextAlignment(.center)
                    .opacity(0.5)

                // Sign In Button
                Button(action: {
                    isNavigatingToSignIn = true
                }) {
                    HStack {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(hex: "26344f"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(10)
                }

                // Login Button
                Button(action: {
                    isNavigatingToLogin = true
                }) {
                    HStack {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color(hex: "26344f"))
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(hex: "26344f"), lineWidth: 1))
                    }
                    .padding(10)
                }

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $isNavigatingToSignIn) {
                RegistrationView() // Navigates to RegistrationView
                    .navigationBarHidden(true)
            }
            .navigationDestination(isPresented: $isNavigatingToLogin) {
                LoginView() // Navigates to LoginView
                    .navigationBarHidden(true)
            }
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
            .environmentObject(BookManager())
    }
}
