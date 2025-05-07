import SwiftUI

struct RegistrationView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isRegistered = false
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Spacer()
                // Title
                Text("Create an account")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.leading)
                
                Text("Find your next great read!")
                    .font(.subheadline)
                    .padding(.leading)
                    .padding(.bottom, 24)
                
                // Form fields
                VStack(alignment: .leading, spacing: 24) {
                    InputView(text: $username,
                              title: "Username",
                              placeholder: "Enter your username")
                    
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "your-email@example.com")
                        .autocapitalization(.none)

                    // Password Field
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

                    // Confirm Password Field
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password",
                              isSecureField: !isConfirmPasswordVisible)
                    .overlay(
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.fill" : "eye.slash.fill")
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
                
                // Sign up button
                Button {
                    validateAndRegister()
                } label: {
                    HStack {
                        Text("Sign up")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(hex: "26344f"))
                    .cornerRadius(10)
                }
                .padding(.top, 24)
                
                Spacer()
                
                // Sign in button
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Spacer()
                        Text("Already have an account?")
                        Text("Log in")
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .font(.system(size: 16))
                }
            }
            .padding()
            .navigationDestination(isPresented: $isRegistered) {
                DiscoverBooks() // Navigate discoverbooks
                    .navigationBarBackButtonHidden(true)
            }
        }
        .foregroundColor(Color(hex: "26344f"))
    }

    // Validate and register
    private func validateAndRegister() {
        if username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "All fields are required."
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match."
        } else if !isValidPassword(password) {
            errorMessage = "Password must contain at least one uppercase letter, one lowercase letter, one number, and one symbol."
        } else {
            errorMessage = nil // Clear the error message if all validations pass
            
            // Call registration method
            Task {
                do {
                    try await viewModel.createUser(withEmail: email, password: password, username: username)
                    isRegistered = true
                } catch {
                    errorMessage = "Registration failed: \(error.localizedDescription)"
                }
            }
        }
    }

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
}

// MARK: - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
            && email.contains("@")
            && !password.isEmpty
            && password.count > 7
            && confirmPassword == password
            && !username.isEmpty
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
