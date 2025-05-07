import SwiftUI
import Firebase
import FirebaseStorage

struct ProfileView: View {
   @EnvironmentObject var bookManager: BookManager
   @EnvironmentObject var viewModel: AuthViewModel
   @State private var selectedImage: UIImage?
   @State private var showingImagePicker = false
   @State private var bio: String = "" {
       didSet {
           updateBioIfNeeded()
       }
   }
   @State private var isEditingGoal = false  // Track if the goal is being edited
   @State private var readingGoal: String = ""  // For input value
   @State private var savedGoal: Int? = nil  // The goal to save
   @State private var goalSetDate: Date? = nil  // Track when the goal was set
   @State private var currentBooksRead: Int = 0  // Number of books read

   // Track the state of completed books before the goal is set
   @State private var completedBooksBeforeGoal: [UUID: Bool] = [:]

   // MARK: - Function to calculate the progress of a book
   private func calculateProgress(book: Book) -> Double {
       let pagesRead = book.pagesRead
       let totalPages = book.pages
       guard totalPages > 0 else { return 0 }
       return min(Double(pagesRead) / Double(totalPages) * 100, 100)
   }

   // MARK: - Function to filter finished books (for Recently Read section)
    private func recentlyFinishedBooks() -> [Book] {
        return bookManager.bookmarkedBooks
            .filter { book in
                // Only show books that are fully read (i.e., pagesRead == pages)
                return book.pagesRead == book.pages
            }
            .sorted { $0.pagesRead > $1.pagesRead }  // Sort by the most recently completed book
            .prefix(3)  // Get the last 3 completed books
            .map { $0 }  // Return the Book objects themselves
    }


   // MARK: - Function to calculate the progress towards the goal
   private func goalProgress() -> Double {
       guard let goal = savedGoal else { return 0 }
       
       // Fetch books read after goal was set and calculate progress
       let booksReadAfterGoal = self.booksReadAfterGoal()
       return min(Double(booksReadAfterGoal) / Double(goal) * 100, 100) // Ensure the progress doesn't exceed 100%
   }

   // MARK: - Function to calculate the number of books read after the goal was set
   private func booksReadAfterGoal() -> Int {
       guard goalSetDate != nil else { return 0 } // If no goal is set, return 0
       
       // Fetch the completed books (those fully read)
       let completedBooks = bookManager.bookmarkedBooks
       
       // Filter out books that were completed before the goal was set (before the goalDate)
       let booksReadAfterGoal = completedBooks.filter { book in
           // Only count books that are fully completed (pagesRead == pages)
           // Exclude books that were completed before the goal was set
           return book.pagesRead == book.pages && !(completedBooksBeforeGoal[book.id] ?? false)
       }
       
       return booksReadAfterGoal.count
   }

   // MARK: - Save Reading Goal Function
    private func saveReadingGoal() {
        guard let goal = Int(readingGoal), goal > 0 else { return } // Ensure the goal is valid
        savedGoal = goal // Set saved goal to the converted integer value
        goalSetDate = Date() // Track when the goal was set
        isEditingGoal = false // Exit editing mode after saving
        
        // Mark completed books before the goal
        markCompletedBooksBeforeGoal()
    }

   // MARK: - Example function to mark completed books before goal
    private func markCompletedBooksBeforeGoal() {
        guard goalSetDate != nil else { return }
        
        // Only mark books once if they haven't been marked before
        for book in bookManager.bookmarkedBooks {
            if book.pagesRead == book.pages && (completedBooksBeforeGoal[book.id] == nil) {
                completedBooksBeforeGoal[book.id] = true
            }
        }
    }
    
    // Fetch and update bio from Firestore
       private func fetchBio() {
           guard let userID = viewModel.currentUser?.id else { return }
           
           let db = Firestore.firestore()
           db.collection("users").document(userID).getDocument { document, error in
               if let document = document, document.exists, let bio = document.get("bio") as? String {
                   self.bio = bio
               } else {
                   print("Error fetching bio: \(error?.localizedDescription ?? "Unknown error")")
               }
           }
       }

       // Save the bio to Firestore
       private func updateBio(_ bio: String) {
           guard let userID = viewModel.currentUser?.id else { return }
           
           let db = Firestore.firestore()
           db.collection("users").document(userID).updateData([
               "bio": bio
           ]) { error in
               if let error = error {
                   print("Error updating bio: \(error.localizedDescription)")
               } else {
                   print("Bio updated successfully.")
               }
           }
       }

   // MARK: - Body
   var body: some View {
       NavigationStack {
           ScrollView {
               VStack(alignment: .center){
                   HStack {
                       Spacer()
                       Text("      Profile")
                           .font(.custom("Avenir-Heavy", size: 18))
                           .foregroundColor(Color(hex: "26344f"))
                       Spacer()
                       gearButton
                   }
                   .padding(.horizontal)
                   
                   // Profile Image Display Logic
                   profileImageView
                   
                   // Username Display
                   usernameView
                   
                   // Bio Text Editor
                   bioTextEditor
               }
                   // MARK: - Recently Read Section Title
               VStack(alignment: .leading) {
                       Text("Recently Read")
                           .font(.custom("Avenir-Heavy", size: 20))
                           .foregroundColor(Color(hex: "26344f"))
                           .multilineTextAlignment(.leading)
                   
                       
                       // MARK: - Recently Read Books
                   VStack(alignment: .leading) {
                           HStack {
                               ForEach(recentlyFinishedBooks()) { book in
                                   NavigationLink(destination: BookDetailsView(book: book)) {
                                       Image(book.imageName)
                                           .resizable()
                                           .scaledToFit()
                                           .scaleEffect(x: 0.8, y: 0.8)
                                           .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)
                                   }
                               }
                           }
                       }
                   }
                   .padding(.horizontal)
                   
               // MARK: - Reading Goal Section
               VStack {
                   HStack {
                       Text("Reading Goal")
                           .font(.custom("Avenir-Heavy", size: 20))
                           .foregroundColor(Color(hex: "26344f"))
                       Spacer()
                       Button(action: {
                           if isEditingGoal {
                               saveReadingGoal()
                           } else {
                               isEditingGoal = true
                           }
                       }) {
                           Text(isEditingGoal ? "Save" : savedGoal == nil ? "Set Goal" : "Edit")
                               .font(.custom("Avenir-Medium", size: 16))
                               .foregroundColor(Color(hex: "698bcc"))
                               .cornerRadius(10)
                               .padding(.top, 16)
                       }
                   }
                   
                   // Show goal details and progress only if not editing
                   if !isEditingGoal {
                       if savedGoal != nil {
                           // Display Reading Goal if set
                           Text("Your Reading Goal: \(savedGoal ?? 0) books")
                               .font(.title2)
                               .fontWeight(.semibold)
                               .foregroundColor(.primary)
                               .padding(.top, 30)
                           
                           // Progress Bar
                           ProgressBar(progress: goalProgress())
                               .frame(height: 10)
                               .padding(.top, 8)
                           
                           Text("\(booksReadAfterGoal()) books read")
                               .font(.subheadline)
                               .padding(.top, 8)
                       }
                   }

                   // Goal Input Field if Editing
                   if isEditingGoal {
                       VStack(alignment: .center) {
                           Text("How many books would you like to read?")
                               .font(.custom("Avenir-Bold", size: 16))
                               .padding(.top, 8)
                               .padding(.bottom, 10)
                               .multilineTextAlignment(.center)
                           
                           TextField("Enter number", text: $readingGoal)
                               .keyboardType(.numberPad)
                               .frame(width: 120, height: 15)
                               .padding()
                               .foregroundColor(Color(hex: "26344f"))
                               .multilineTextAlignment(.center)
                               .background(Color(hex: "698bcc").opacity(0.25))
                               .cornerRadius(10)
                               .font(.headline)
                               .overlay(
                                   RoundedRectangle(cornerRadius: 10)
                                       .stroke(Color(hex: "698bcc").opacity(0.25), lineWidth: 1)
                               )
                       }
                       .padding(.top, 16)
                       .padding(.bottom, 20)
                   }
               }
               .padding(.horizontal)
               .contentShape(Rectangle())
               .onTapGesture {
                   // Dismiss the keyboard
                   UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                   Task {
                       await updateBio(bio) // Automatically save
                   }
               }
               .sheet(isPresented: $showingImagePicker) {
                   ImagePicker(image: $selectedImage, onImagePicked: uploadImage)
               }
               .onAppear {
                   bio = viewModel.currentUser?.bio ?? "" // Load existing bio
               }
           }
       }
   }

   // MARK: - Gear Button
   private var gearButton: some View {
       NavigationLink(destination: SettingsView()) {
           Image(systemName: "gear")
               .resizable()
               .frame(width: 25, height: 25)
               .foregroundColor(Color(hex: "26344f"))
       }
   }

   // MARK: - Profile Image View
   private var profileImageView: some View {
       Group {
           if let selectedImage = selectedImage {
               Image(uiImage: selectedImage)
                   .resizable()
                   .scaledToFit()
                   .frame(width: 100, height: 100)
                   .clipShape(Circle())
                   .padding()
                   .onTapGesture { showingImagePicker = true }
           } else if let imageUrl = viewModel.currentUser?.profileImageUrl,
                     let url = URL(string: imageUrl) {
               AsyncImage(url: url) { image in
                   image
                       .resizable()
                       .scaledToFit()
                       .frame(width: 100, height: 100)
                       .clipShape(Circle())
                       .padding()
                       .onTapGesture {
                           showingImagePicker = true
                       }
               } placeholder: {
                   Image(systemName: "person.circle.fill")
                       .resizable()
                       .scaledToFit()
                       .frame(width: 100, height: 100)
                       .foregroundColor(.gray)
                       .clipShape(Circle())
                       .padding()
                       .onTapGesture {
                           showingImagePicker = true
                       }
               }
           } else {
               Image(systemName: "person.circle.fill")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 100, height: 100)
                   .foregroundColor(.gray)
                   .clipShape(Circle())
                   .padding()
                   .onTapGesture {
                       showingImagePicker = true
                   }
           }
       }
   }

    // MARK: - Username View
       private var usernameView: some View {
           Group {
               if let username = viewModel.currentUser?.username {
                   HStack {
                       Text("@")
                           .font(.headline)
                           .padding(.top, 2)
                       Text(username)
                           .font(.headline)
                           .padding(.top, 2)
                   }
               } 
           }
       }

   // MARK: - Bio Text Editor with Placeholder
   private var bioTextEditor: some View {
       ZStack(alignment: .topLeading) {
           TextEditor(text: $bio)
               .frame(height: 85)
               .opacity(0.5)
               .multilineTextAlignment(.center)
               .padding(8)
               .cornerRadius(8)
               .padding(.horizontal)

           if bio.isEmpty {
               Text("Add Bio")
                   .foregroundColor(.gray)
                   .multilineTextAlignment(.center)
                   .frame(maxWidth: .infinity, alignment: .center)
                   .padding(12)
           }
       }
   }

   // MARK: - Update Bio Function
    private func updateBioIfNeeded() {
        let wordLimit = 25 // Set your maximum word count here
        let wordCount = bio.split { $0.isWhitespace || $0.isNewline }.count
        
        if wordCount > wordLimit {
            // Trim the text to the maximum number of words allowed
            let words = bio.split { $0.isWhitespace || $0.isNewline }
            bio = words.prefix(wordLimit).joined(separator: " ")
        }
        
        Task {
            await updateBio(bio)
        }
    }

   // MARK: - Upload Selected Image to Firebase
   private func uploadImage(_ image: UIImage) {
       guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
       
       let storageRef = Storage.storage().reference()
       let userId = viewModel.currentUser?.id ?? UUID().uuidString
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
               viewModel.updateProfileImageUrl(downloadURL)
           }
       }
   }

   // MARK: - Update Bio Function
   private func updateBio(_ bio: String) async {
       do {
           try await viewModel.updateBio(to: bio)
       } catch {
           print("Error saving bio: \(error.localizedDescription)")
       }
   }
}


// MARK: - Preview
struct ProfileView_Previews: PreviewProvider {
   static var previews: some View {
       // Create a mock BookManager with some finished and in-progress books
       let mockBookManager = BookManager()
       mockBookManager.bookmarkedBooks = [
           Book(id: UUID(), imageName: "vch", title: "Verity", author: "Colleen Hoover", rating: 4.5, description: "A psychological thriller.", pages: 340, pagesRead: 340, publisher: "Montlake", isbn: "978-1542019669", released: "2018-01-18", genres: ["Thriller", "Romance"], numberOfRatings: 1448236, ratingsDistribution: [698236, 450000, 150000, 100000, 50000], about: "Colleen Hoover is the #1 New York Times bestselling author."),
           Book(id: UUID(), imageName: "tuhm", title: "The Unhoneymooners", author: "Christina Lauren", rating: 4.4, description: "A hilarious romantic comedy.", pages: 368, pagesRead: 250, publisher: "Gallery Books", isbn: "978-1501128035", released: "2019-05-14", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236, 450000, 150000, 100000, 50000], about: "Christina Lauren is a coauthor duo."),
           Book(id: UUID(), imageName: "br", title: "Beach Read", author: "Emily Henry", rating: 4.7, description: "A romantic comedy.", pages: 368, pagesRead: 368, publisher: "Gallery Books", isbn: "978-1501128035", released: "2019-05-14", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236, 450000, 150000, 100000, 50000], about: "Emily Henry is a New York Times bestselling author."),
           Book(id: UUID(), imageName: "bl", title: "Book Lovers", author: "Emily Henry", rating: 4.8, description: "A romantic comedy.", pages: 368, pagesRead: 368, publisher: "Gallery Books", isbn: "978-1501128035", released: "2019-05-14", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236, 450000, 150000, 100000, 50000], about: "Emily Henry is a New York Times bestselling author."),
           Book(id: UUID(), imageName: "acotar", title: "Acotar ", author: "SJM ", rating: 4.9, description: "A romantic comedy.", pages: 368, pagesRead: 368, publisher: "Gallery Books", isbn: "978-1501128035", released: "2019-05-14", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236, 450000, 150000, 100000, 50000], about: "Emily Henry is a New York Times bestselling author.")
       ]
       return ProfileView()
           .environmentObject(mockBookManager)
           .environmentObject(AuthViewModel())
           .environmentObject(BookManager())
   }
}
