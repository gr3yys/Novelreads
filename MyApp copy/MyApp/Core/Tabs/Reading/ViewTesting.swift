import SwiftUI

struct ViewTesting: View {
    @EnvironmentObject var bookManager: BookManager
    @State private var pagesRead: String = ""

    // Function to filter finished books
    private func recentlyFinishedBooks() -> [Book] {
            return bookManager.bookmarkedBooks
                .filter { book in
                    let progress = calculateProgress(book: book)
                    return progress == 100.0
                }
                .sorted { $0.bookmarkDate ?? Date() > $1.bookmarkDate ?? Date() } // Sort by the most recent bookmarkDate
                .suffix(3) // Get the last 3 finished books
                .map { $0 } // Convert the result back to an array
        }

    var body: some View {
        NavigationView {
            VStack {
                Text("Recently Finished Books")
                    .fontWeight(.heavy)
                    .foregroundColor(Color(hex: "26344f"))
                    .padding()

                ScrollView {
                    VStack(spacing: 20) {
                        // In Progress Section
                        Text("In Progress")
                            .font(.headline)
                            .foregroundColor(Color(hex: "26344f"))
                        
                        ForEach(bookManager.bookmarkedBooks) { book in
                            if calculateProgress(book: book) < 100 {
                                NavigationLink(destination: ReadingLog(
                                    imageName: book.imageName,
                                    title: book.title,
                                    author: book.author,
                                    book: book,
                                    startDate: book.bookmarkDate ?? Date(),
                                    pagesRead: book.pagesRead
                                )) {
                                    BookCard(
                                        imageName: book.imageName,
                                        title: book.title,
                                        author: book.author,
                                        totalPages: book.pages,
                                        book: book,
                                        bookManager: bookManager
                                    )
                                    .padding()
                                }
                            }
                        }
                        
                        // Recently Finished Section
                        Text("Recently Finished")
                            .font(.headline)
                            .foregroundColor(Color(hex: "26344f"))
                        
                            VStack(alignment: .center) {
                                HStack(spacing: -70) { // Adjusted spacing for horizontal scroll
                                    ForEach(recentlyFinishedBooks()) { book in
                                        NavigationLink(destination: BookDetailsView(book: book)) { // Assuming you have BookDetailsView
                                            HStack {
                                                Image(book.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 160, height: 160)
                                                    .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)
                                                    .padding()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    // Calculate the progress for each book
    private func calculateProgress(book: Book) -> Double {
        let pagesRead = book.pagesRead
        return book.pages > 0 ? Double(pagesRead) / Double(book.pages) * 100 : 0
    }
}

struct ViewTesting_Previews: PreviewProvider {
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
        
        return ViewTesting()
            .environmentObject(mockBookManager)
    }
}
