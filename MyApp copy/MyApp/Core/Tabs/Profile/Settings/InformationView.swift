import SwiftUI

struct InformationView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer()
                    Text("Information")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "26344f"))
                    
                    Text("Novelreads is your ideal mobile app for discovering books and tracking your reading progress. Designed for book lovers, it offers an intuitive and enriching experience.")
                        .foregroundColor(Color(hex: "26344f"))
                    
                    Text("Key Features")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "26344f"))
                    
                    // Listed Features
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "Book Discovery: Explore a list of new and popular books on the Discover screen. Easily find titles with our search bar.")
                        
                        BulletPoint(text: "Book Details: Tap any book to access complete information, including descriptions, genres, and ratings. Add books to your reading list with a single tap.")
                        
                        BulletPoint(text: "Reading Tracking: On the Reading screen, you can update your progress and keep a record of your reads.")
                        
                        BulletPoint(text: "Personalized Bookshelf: The Bookshelf screen organizes all your books into categories, allowing you to filter by author, title, or date.")
                        
                        BulletPoint(text: "User Profile: Access your information, recently read books, and reading challenges on the Profile screen. Adjust your settings with ease.")
                    }
                    
                    // Support
                    Text("Support")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "26344f"))
                    
                    HStack {
                        Text("Need help? Contact our support team at novelreads@example.com")
                            .foregroundColor(Color(hex: "26344f"))
                    }
                    
                    // Feedback
                    Text("Feedback")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(hex: "26344f"))
                    
                    Text("We’d love to hear from you! Share your thoughts and suggestions to help us improve.")
                        .foregroundColor(Color(hex: "26344f"))
                }
                .padding(.horizontal)
            }
        }
    }
}

struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text("•")
                .font(.body)
            Text(text)
                .font(.body)
        }
    }
}

#Preview {
    InformationView()
}
