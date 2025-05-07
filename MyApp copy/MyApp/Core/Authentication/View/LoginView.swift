import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var isPasswordVisible = false
    @State private var errorMessage: String?
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer()
                
                // Title
                Text("Hi, Welcome Back!")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.leading)
                
                // Subtitle
                Text("Continue your reading journey")
                    .font(.subheadline)
                    .padding(.leading)
                    .padding(.bottom, 24)
                
                // Form fields
                VStack(alignment: .leading, spacing: 24) {
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "your-email@example.com")
                    .autocapitalization(.none)
                    
                    // Show/Hide password
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Please enter your password",
                              isSecureField: !isPasswordVisible)
                    .overlay(
                        Button(action: {
                            isPasswordVisible.toggle()
                        }) {
                            Image(systemName: isPasswordVisible ? "eye.fill" : "eye.slash.fill")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8),
                        alignment: .trailing
                    )
                    
                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Sign in button
                Button {
                    // Validate fields
                    if email.isEmpty || password.isEmpty {
                        errorMessage = "All fields are required."
                    } else if !isValidEmail(email) {
                        errorMessage = "Please enter a valid email address (must contain '@' and a domain)."
                    } else if !isValidPassword(password) {
                        errorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one symbol."
                    } else {
                        errorMessage = nil // Clear error message
                        Task {
                            do {
                                try await viewModel.signIn(withEmail: email, password: password)
                                isLoggedIn = true
                            } catch {
                                // Handle the error
                                print("Sign in error: \(error.localizedDescription)")
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text("Log in")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color(hex: "26344f"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(10)
                    .cornerRadius(15)
                }
                .padding(.top, 24)

                Spacer()
                
                // Sign up button
                NavigationLink {
                    RegistrationView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Spacer()
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .font(.system(size: 16))
                }
            }
            .padding()
            .navigationDestination(isPresented: $isLoggedIn) {
                DiscoverBooks() // Navigate to page when logged in
                    .navigationBarBackButtonHidden(true)
            }
        }
        .foregroundColor(Color(hex: "26344f"))
    }
    
    // Validate password against requirements
    private func isValidPassword(_ password: String) -> Bool {
        let uppercase = NSCharacterSet.uppercaseLetters
        let lowercase = NSCharacterSet.lowercaseLetters
        let numbers = NSCharacterSet.decimalDigits
        let symbols = NSCharacterSet.punctuationCharacters

        return password.rangeOfCharacter(from: uppercase) != nil &&
               password.rangeOfCharacter(from: lowercase) != nil &&
               password.rangeOfCharacter(from: numbers) != nil &&
               password.rangeOfCharacter(from: symbols) != nil
    }
    
    // Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthViewModel())
            .environmentObject(BookManager())
    }
}
