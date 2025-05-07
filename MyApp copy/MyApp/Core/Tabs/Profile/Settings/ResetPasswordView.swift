import SwiftUI

struct ResetPasswordView: View {
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Reset Password")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "26344f"))
                    .padding(.horizontal)
                    .padding(.top, 40)

                Text("Your new password must be different than your previously used passwords.")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(Color(hex: "26344f"))
                    .opacity(0.5)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 24) {
                    InputView(text: $password,
                              title: "New Password",
                              placeholder: "Please enter your new password",
                              isSecureField: true)

                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Please confirm your new password",
                              isSecureField: true)

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    Button(action: {
                        validateAndResetPassword()
                    }) {
                        Text("Reset Password")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "26344f"))
                            .cornerRadius(10)
                    }
                }.foregroundColor(Color(hex: "26344f"))
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding()
            Spacer()
        }
    }

    private func validateAndResetPassword() {
        if password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "Both fields are required."
        } else if password != confirmPassword {
            errorMessage = "Passwords do not match."
        } else {
            errorMessage = nil
            Task {
                do {
                    try await viewModel.resetPassword(to: password)
                    print("Password reset successfully.")
                } catch {
                    errorMessage = "Failed to reset password: \(error.localizedDescription)"
                }
            }
        }
    }
}

#Preview {
    ResetPasswordView()
}
