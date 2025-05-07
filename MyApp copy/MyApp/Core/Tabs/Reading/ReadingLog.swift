//
// ReadingLog.swift
// My App
//

import SwiftUI

struct ReadingLog: View {
    let imageName: String
    let title: String
    let author: String
    let book: Book
    let startDate: Date
    let pagesRead: Int
    
    @State private var isBookmarked: Bool = false
    @EnvironmentObject var bookManager: BookManager
    @State private var selectedShelf: String?
    @State private var showingShelfList = false
    @State private var finishedDate: String? = nil
    @State private var progressPercentage: Double = 0
    @State private var review = ""
    @State private var rating: Double = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
                    .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .bottom) {
                        Text(title)
                            .font(.custom("Avenir-Heavy", size: 24))
                            .foregroundColor(Color(hex: "26344f"))
                            .padding(.top)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()

                        // Bookmark Action
                        Button(action: {
                            bookManager.toggleBookmark(for: book)
                            isBookmarked = bookManager.isBookmarked(book)
                        }) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(Color(hex: "698bcc"))
                                .padding(.top, 8)
                        }
                    }
                    
                    Text(author)
                        .font(.custom("Avenir-Medium", size: 18))
                        .foregroundColor(Color(hex: "26344f"))
                        .padding(.top, 2)
                }
            
                HStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text("Date")
                        Text("\(formattedDate(startDate))")
                            .opacity(0.5)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Pages")
                        Text("\(pagesRead)")
                            .opacity(0.5)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Progress")
                        Text("\(progressPercentage, specifier: "%.0f%%")")
                            .opacity(0.5)
                    }
                    
                    VStack(spacing: 5) {
                        Text("Finsihed")
                        Text(finishedDate ?? "N/A")
                            .opacity(0.5)
                    }
                }
                .font(.custom("Avenir-Medium", size: 18))
                .foregroundColor(Color(hex: "26344f"))
                
                VStack(alignment: .leading, spacing: 18) {
                    Text("Your rating")
                    YourRating(rating: $rating)
                    
                    VStack(alignment: .leading) {
                        Text("Write a Review")
                            .font(.custom("Avenir-Heavy", size: 18))
                            .foregroundColor(Color(hex: "26344f"))
                        
                        TextField("", text: $review)
                            .padding(.top, -40)
                            .padding()
                            .frame(height: 100)
                            .font(.custom("Avenir-Regular", size: 16))
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(hex: "26344f").opacity(0.5), lineWidth: 1)
                            )
                        
                        Button(action: {
                            showingShelfList = true
                        }) {
                            Text("Add to Bookshelf")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(hex: "26344f"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 18)
                        .sheet(isPresented: $showingShelfList) {
                            ShelfListView(selectedShelf: $selectedShelf, onSelect: addBookToShelf)
                        }
                    }
                }
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(Color(hex: "26344f"))
            }
            .padding()
            .navigationTitle("Reading Log")
            .onAppear {
                isBookmarked = bookManager.isBookmarked(book)
                // Calculate progress and set finishedDate if necessary
                progressPercentage = calculateProgressPercentage(pagesRead: pagesRead, totalPages: book.pages)

                // Set finishedDate when progress is 100%
                if progressPercentage == 100 && finishedDate == nil {
                    finishedDate = formattedDate(Date())
                    
                    saveCompletedBook()
                }
            }
        }
    }
    
    private func saveCompletedBook() {
            // Save the book to the completed books list if progress is 100%
            bookManager.addBookToCompleted(book: book)
        }
    
    private func addBookToShelf() {
        guard let shelf = selectedShelf else {
            print("No shelf selected")
            return
        }

        // Add the book to the selected shelf in the BookManager
        bookManager.addBook(to: shelf, book: book)
        print("Added \(book.title) to \(shelf) shelf")
    }
    
    private func calculateProgressPercentage(pagesRead: Int, totalPages: Int) -> Double {
        return totalPages > 0 ? Double(pagesRead) / Double(totalPages) * 100 : 0
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}


// MARK: - Shelf List View
struct ShelfListView: View {
    @Binding var selectedShelf: String?
    var onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var bookManager: BookManager

    var shelves: [String] {
        bookManager.getShelfNames()
    }

    var body: some View {
        NavigationView {
            List(shelves, id: \.self) { shelf in
                Button(action: {
                    selectedShelf = shelf
                    onSelect()
                    dismiss()
                }) {
                    Text(shelf)
                }
            }
            .navigationTitle("Choose Shelf")
            .navigationBarItems(trailing: Button("Cancel") {
                selectedShelf = nil
                dismiss()
            })
        }
    }
}

// MARK: - SHelf view
struct ShelfView: View {
    let shelfName: String
    @EnvironmentObject var bookManager: BookManager

    var body: some View {
        // Get books for the selected shelf
        let books = bookManager.getBooks(for: shelfName)
        
        List(books, id: \.id) { book in
            Text(book.title)
        }
        .navigationTitle(shelfName)
    }
}



// MARK: - Your Rating
struct YourRating: View {
    @Binding var rating: Double

    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .foregroundColor(index < Int(rating) ? .yellow : Color(hex: "26344f").opacity(0.25))
                    .onTapGesture {
                        rating = Double(index + 1) // Set rating based on tapped star
                    }
            }
        }
//        .frame(maxWidth: .infinity)
    }
}

#Preview {
    let sampleBook = Book(
        id: UUID(),
        imageName: "dr",
        title: "Divine Rivals",
        author: "Rebecca Ross",
        rating: 4,
        description: "An engaging fantasy novel.",
        pages: 300,
        publisher: "Publisher Name",
        isbn: "1234567890",
        released: "October 1, 2024",
        genres: ["Fantasy", "Adventure"],
        numberOfRatings: 150,
        ratingsDistribution: [10, 20, 30, 40, 50],
        about: "This is a book about..."
    )
    ReadingLog(
        imageName: sampleBook.imageName,
        title: sampleBook.title,
        author: sampleBook.author,
        book: sampleBook,
        startDate: Date(),
        pagesRead: 150
    )
    .environmentObject(BookManager())
}
