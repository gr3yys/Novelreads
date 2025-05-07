import SwiftUI

struct ChangeNameView: View {
    @State private var fullname = ""
    @State private var errorMessage: String?
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Change Username")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "26344f"))
                    .padding(.horizontal)
                    .padding(.top, 40)

                Text("Your new name must be different than your current name.")
                    .font(.subheadline)
                    .fontWeight(.light)
                    .foregroundColor(Color(hex: "26344f"))
                    .opacity(0.5)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 24) {
                    InputView(text: $fullname,
                              title: "New Username",
                              placeholder: "Please enter your new username")

                    Text("Please only use numbers, letters, underscores, and periods.")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "26344f"))
                        .opacity(0.5)

                    if let errorMessage = errorMessage {
                        HStack {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.footnote)
                        }
                    }

                    Button(action: {
                        if fullname.isEmpty {
                            errorMessage = "Name cannot be empty."
                        } else {
                            errorMessage = nil
                            Task {
                                do {
                                    try await viewModel.changeName(to: fullname)
                                    print("Name changed to: \(fullname)")
                                } catch {
                                    errorMessage = "Failed to change name: \(error.localizedDescription)"
                                }
                            }
                        }
                    }) {
                        Text("Confirm")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(hex: "26344f"))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
            .padding()
            Spacer()
        }
    }
}


#Preview {
    ChangeNameView()
}
