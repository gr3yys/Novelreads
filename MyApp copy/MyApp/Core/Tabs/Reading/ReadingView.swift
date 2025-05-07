// ReadingView.swift
// MyApp
//
// Created by greys on 10/9/24.
//

import SwiftUI

// Book Card
struct BookCard: View {
    let imageName: String
    let title: String
    let author: String
    let totalPages: Int

    let book: Book

    @State private var pagesRead: String = ""
    @State private var isEditing = false
    @State private var selectedDate: Date?
    @ObservedObject var bookManager: BookManager

    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .padding(.horizontal, -15)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            handleSave()
                        }
                        isEditing.toggle()
                    }
                    .font(.footnote)
                    .padding(.top, 0)
                    .padding(.horizontal, 2)
                    .foregroundColor(Color(hex: "698bcc"))
                }

                    Text(author)
                        .font(.subheadline)
                        .padding(.bottom)
                    
                        if !isEditing, let bookmarkDate = book.bookmarkDate {
                            Text("Started \(formattedDate(bookmarkDate))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        // Date picker
                        if isEditing {
                            DatePicker("Started", selection: Binding(
                                get: { selectedDate ?? book.bookmarkDate ?? Date() },
                                set: { newDate in
                                    selectedDate = newDate
                                    updateBookmarkDate()
                                }
                            ), displayedComponents: .date)
                            .datePickerStyle(DefaultDatePickerStyle())
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                
                // Progress Bar
                HStack {
                    ProgressBar(progress: calculateProgress())
                        .frame(height: 10)

                    Text("\(calculateProgressPercentage(), specifier: "%.0f%%")")
                        .font(.footnote)
                        .foregroundColor(Color(hex: "26344f"))
                        .opacity(0.5)
                }

                // Pages read
                if isEditing {
                    HStack {
                        TextField("Read", text: $pagesRead)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .keyboardType(.numberPad)
                            .font(.footnote)
                            .cornerRadius(5)

                        Text("/ \(totalPages) pages")
                            .font(.footnote)
                            .foregroundColor(Color(hex: "26344f"))
                    }
                }
            }
        }
        .padding(12)
        .foregroundColor(Color(hex: "26344f"))
        .background(Color.white)
        .cornerRadius(5)
        .shadow(color: .gray.opacity(0.5), radius: 5, x: 0, y: 2)
    }

    // Save pages read
    private func handleSave() {
        guard let pages = Int(pagesRead), pages >= 0, pages <= totalPages else {
            return
        }

        // Update the book's pagesRead in the BookManager
        if let index = bookManager.bookmarkedBooks.firstIndex(where: { $0.id == book.id }) {
            bookManager.bookmarkedBooks[index].pagesRead = pages
        }
        print("Pages read: \(pages)")
    }

    
    // Date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    private func calculateProgress() -> Double {
        let pages = Int(pagesRead) ?? 0
        return totalPages > 0 ? Double(pages) / Double(totalPages) * 100 : 0
    }

    private func calculateProgressPercentage() -> Double {
        totalPages > 0 ? Double(Int(pagesRead) ?? 0) / Double(totalPages) * 100 : 0
    }

    // Date
    private func updateBookmarkDate() {
        if let index = bookManager.bookmarkedBooks.firstIndex(where: { $0.id == book.id }) {
            bookManager.bookmarkedBooks[index].bookmarkDate = selectedDate
        }
    }
}

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: "26344f"))
                    .opacity(0.15)
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color(hex: "698bcc"))
                    .frame(width: geometry.size.width * progress / 100)
            }
        }
    }
}

// Cards Display
struct ReadingView: View {
    @EnvironmentObject var bookManager: BookManager
    @State private var pagesRead: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Currently Reading")
                    .fontWeight(.heavy)
                    .foregroundColor(Color(hex: "26344f"))
                    .padding()
                
                HStack {
                    Text("In Progress")
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "26344f"))
                    
                    Spacer()
                    
                    Text("\(bookManager.bookmarkedBooks.count)")
                        .font(.headline)
                        .foregroundColor(Color(hex: "26344f"))
                }
                .padding(.horizontal)
                .padding(.vertical)

                ScrollView {
                    VStack(spacing: -15) {
                        ForEach(bookManager.bookmarkedBooks) { book in
                            NavigationLink(destination: ReadingLog(
                                imageName: book.imageName,
                                title: book.title,
                                author: book.author,
                                book: book,
                                startDate: book.bookmarkDate ?? Date(),
                                pagesRead: book.pagesRead
                                )){
                                
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
                }
            }
        }
    }
}

// Preview
struct ReadingView_Previews: PreviewProvider {
    static var previews: some View {
        let mockBookManager = BookManager()
        mockBookManager.bookmarkedBooks = [
            Book(id: UUID(), imageName: "vch", title: "Verity", author: "Colleen Hoover", rating: 4.5, description: "A psychological thriller that will keep you on the edge of your seat.", pages: 340, publisher: "Montlake", isbn: "978-1542019669", released: "January 18, 2018", genres: ["Thriller", "Romance"], numberOfRatings: 1448236, ratingsDistribution: [698236,450000,150000,100000, 50000], about: "Colleen Hoover is the #1 New York Times bestselling author of twenty four novels and novellas. Hoover’s novels fall into the New Adult and Young Adult contemporary romance categories, as well as psychological thriller. \n\nColleen Hoover is published by Atria Books, Grand Central Publishing, Montlake Romance, and HarperCollins Publishers. \n\nIn 2015, Colleen’s novel CONFESS won the Goodreads Choice Award for Best Romance. That was followed up in 2016 with her latest title, It Ends With Us, also winning the Choice Award for Best Romance. In 2017, her title WITHOUT MERIT won best romance. \n\nHer novel CONFESS has been filmed as a series by Awestruck and is available on Prime Video via Amazon and iTunes. Katie Leclerc and Ryan Cooper star in the series."),
            Book(id: UUID(), imageName: "tuhm", title: "The Unhoneymooners", author: "Christina Lauren", rating: 4.4, description: "A hilarious romantic comedy about a wedding gone wrong.", pages: 368, publisher: "Gallery Books", isbn: "978-1501128035", released: "May 14, 2019", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236,450000,150000,100000, 50000], about: "Christina Lauren is the combined pen name of long-time writing partners and best friends Christina Hobbs and Lauren Billings. The #1 international bestselling coauthor duo writes both Young Adult and Adult Fiction, and together has produced twenty New York Times bestselling novels."),
            Book(id: UUID(), imageName: "br", title: "Beach Read", author: "Emily Henry", rating: 4.7, description: "A hilarious romantic comedy about a wedding gone wrong.", pages: 368, publisher: "Gallery Books", isbn: "978-1501128035", released: "May 14, 2019", genres: ["Romance", "Comedy"], numberOfRatings: 1448236, ratingsDistribution: [698236,450000,150000,100000, 50000], about: "Christina Lauren is the combined pen name of long-time writing partners and best friends Christina Hobbs and Lauren Billings. The #1 international bestselling coauthor duo writes both Young Adult and Adult Fiction, and together has produced twenty New York Times bestselling novels.")
        ]
        
        return ReadingView()
            .environmentObject(mockBookManager)
    }
}


// Helper to define Color with hex
extension Color {
    init(hex: String) {
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
