import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var shouldShowLoginView: Bool = false
    @Published var isLoading: Bool = true // To track loading state

    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    // Log in
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = authResult.user
            await fetchUser()
        } catch {
            print("DEBUG: Failure to log in with error \(error.localizedDescription)")
            throw error
        }
    }

    // Register
    func createUser(withEmail email: String, password: String, username: String, bio: String = "") async throws {
        do {
            let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = authResult.user
            let user = User(id: authResult.user.uid, username: username, email: email, profileImageUrl: nil, bio: bio)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch let error as NSError {
            print("DEBUG: Error creating user: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Update profile image URL
    func updateProfileImageUrl(_ url: String) {
        currentUser?.profileImageUrl = url
    }
    
    // Update bio
    func updateBio(to newBio: String) async throws {
        guard let user = userSession else { return }

        let updateData: [String: Any] = ["bio": newBio]

        // Update Firestore
        let db = Firestore.firestore()
        try await db.collection("users").document(user.uid).updateData(updateData)

        // Optionally, refresh the currentUser to reflect the updated bio
        await fetchUser()
    }

    // Name change
    func changeName(to newName: String) async throws {
        guard let user = userSession else {
            throw NSError(domain: "User not logged in", code: 0)
        }

        let updateData: [String: Any] = ["username": newName]
        try await updateUserFullName(uid: user.uid, updateData: updateData)
        print("DEBUG: User name successfully updated to \(newName).")
        await fetchUser() // Refresh the user data
    }

    // Helper function to update username in Firestore
    private func updateUserFullName(uid: String, updateData: [String: Any]) async throws {
        let db = Firestore.firestore()
        try await db.collection("users").document(uid).updateData(updateData)
    }

    // Password reset
    func resetPassword(to newPassword: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "User not logged in", code: 0)
        }

        do {
            try await currentUser.updatePassword(to: newPassword)
            print("DEBUG: Password updated successfully.")
        } catch let error as NSError {
            print("DEBUG: Error updating password: \(error.localizedDescription)")
            throw error
        }
    }

    // Sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
            email = ""
            password = ""
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }

    // Delete Account
    func deleteAccount() async throws {
        guard let user = userSession else { return }

        // Delete user data from Firestore
        try await deleteUserData()

        // Delete the user account from Firebase Authentication
        try await user.delete()
        userSession = nil
    }

    // Deletes user data from Firestore
    private func deleteUserData() async throws {
        guard let userID = userSession?.uid else { throw NSError(domain: "User not logged in", code: 0) }

        let db = Firestore.firestore()
        try await db.collection("users").document(userID).delete()
        print("DEBUG: User data successfully deleted.")
    }

    // Fetch user data from Firestore
    func fetchUser() async {
        guard let userID = userSession?.uid else { return }
        
        do {
            let document = try await Firestore.firestore().collection("users").document(userID).getDocument()
            if let data = document.data() {
                let user = try Firestore.Decoder().decode(User.self, from: data)
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoading = false // Stop loading once user is fetched
                }
            }
        } catch let error as NSError {
            print("DEBUG: Error fetching user: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false // Stop loading on error
            }
        }
    }
    
    // Upload Profile Image to Firebase Storage
    func uploadProfileImage(_ image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let storageRef = Storage.storage().reference()
        let userId = self.currentUser?.id ?? UUID().uuidString
        let profileImageRef = storageRef.child("profileImages/\(userId).jpg")

        profileImageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                return
            }

            profileImageRef.downloadURL { url, error in
                if let error = error {
                    print("Error getting download URL: \(error.localizedDescription)")
                    return
                }
                guard let downloadURL = url?.absoluteString else { return }
                self.updateProfileImageUrl(downloadURL)
                // Optionally, update Firestore with the new profile image URL
                self.updateProfileImageInFirestore(downloadURL)
            }
        }
    }

    // Update profile image URL in Firestore
    private func updateProfileImageInFirestore(_ url: String) {
        guard let userId = userSession?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(["profileImageUrl": url])
    }
}
