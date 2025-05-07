//
//  DiscoverBooks.swift
//  MyApp
//
//  Created by greys on 10/6/24.
//

import SwiftUI

// MARK: - Color
extension Color {
    init(hex: String, opacity: Double = 1.0) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)

        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0

        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}

// MARK: - Book struct
struct Book: Identifiable, Codable {
    let id: UUID
    let imageName: String
    let title: String
    let author: String
    let rating: Double
    let description: String
    let pages: Int
    var pagesRead: Int = 0
    let publisher: String
    let isbn: String
    let released: String
    let genres: [String]
    let numberOfRatings: Int
    let ratingsDistribution: [Int]
    let about: String
    var bookmarkDate: Date?
    var finishDate: Date?
}

// MARK: - Book Model
class BooksViewModel: ObservableObject {
    @Published var allBooks: [Book] = []
    @Published var recommendedBooks: [Book] = []
    @Published var popularBooks: [Book] = []

    init() {
        
        loadBooks()
    }

    func loadBooks() {
        
        allBooks = []
        recommendedBooks = []
        popularBooks = []
    }
}

// MARK: - Body
struct DiscoverBooks: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @EnvironmentObject var booksViewModel: BooksViewModel
    @State private var searchText: String = ""

    // MARK: -  Search Function
    var filteredBooks: [Book] {
        let combinedBooks = allBooks + recommendedBooks + popularBooks
        if searchText.isEmpty {
            return []
        } else {
            return combinedBooks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    VStack(spacing: 20) {
                        headerView(title: "    Discover Books")
                        searchBarView()
                        
                        // Show sections only if searchText is empty
                        if searchText.isEmpty {
                            sectionView(title: "All Books", books: allBooks, showArrow: true)
                            sectionView(title: "Recommended", books: recommendedBooks, showArrow: true)
                            sectionView(title: "Popular Genres", books: popularBooks, showArrow: true)
                        } else {
                            searchResultsView()
                        }
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("Discover", systemImage: "magnifyingglass")
            }
            
            ReadingView()
                .tabItem {
                    Label("Reading", systemImage: "book")
                }
            
            BookshelfView()
                .tabItem {
                    Label("Bookshelf", systemImage: "books.vertical")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }

    // MARK: -  sub navigation title
    private func headerView(title: String) -> some View {
        HStack {
            Spacer()
            Text(title)
                .foregroundColor(Color(hex: "26344f"))
                .font(.custom("Avenir-Heavy", size: 18))
            Spacer()
            Image(systemName: "ellipsis")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color(hex: "26344f"))
        }
        .padding(.vertical)
    }
    
    // MARK: -  Search Bar
    private func searchBarView() -> some View {
        ZStack(alignment: .leading) {
            TextField("Search", text: $searchText)
                .padding(15)
                .padding(.leading, 40)
                .foregroundColor(Color(hex: "26344f"))
                .background(Color(hex: "698bcc").opacity(0.1))
                .cornerRadius(24)
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(Color(hex: "26344f"))
                .opacity(0.8)
                .padding(.leading, 10)
        }
        .padding(.horizontal, 10)
    }

    // MARK: -  Book Sections
    private func sectionView(title: String, books: [Book], showArrow: Bool) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.custom("Avenir-Heavy", size: 20))
                    .foregroundColor(Color(hex: "26344f"))
                    .padding(.leading)

                Spacer()

                if showArrow {
                    NavigationLink(destination: destinationView(for: title, books: books)) {
                        Image(systemName: "line.diagonal.arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 52)
                            .rotationEffect(.degrees(45))
                            .foregroundColor(Color(hex: "26344f"))
                            .padding(.trailing)
                    }
                }
            }

            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(books.prefix(3)) { book in
                    BookImageView(book: book) // preview the image
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: -  display only the image
    struct BookImageView: View {
        let book: Book

        var body: some View {
            NavigationLink(destination: BookDetailsView(book: book)) {
                Image(book.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)
            }
        }
    }

    // MARK: -  Results from search
    private func searchResultsView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Search Results")
                    .font(.headline)
                    .foregroundColor(Color(hex: "26344f"))
                
                Spacer()
                
                Text("\(filteredBooks.count)")
                    .font(.headline)
                    .foregroundColor(Color(hex: "26344f"))
            }
            .opacity(0.5)
            .padding(.bottom, 10)
            
            // Display searched books
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                ForEach(filteredBooks) { book in
                    BookDisplayView(book: book)
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func destinationView(for title: String, books: [Book]) -> some View {
        switch title {
        case "All Books":
            let combinedBooks = allBooks + recommendedBooks + popularBooks
            AllBooksView(books: combinedBooks)
        case "Recommended":
            RecommendedBooksView(books: books)
        case "Popular Genres":
            PopularGenresView(books: books)
        default:
            Text("No View")
        }
    }
}

// MARK: -  Reusable Book Display View
struct BookDisplayView: View {
    let book: Book

    var body: some View {
        NavigationLink(destination: BookDetailsView(book: book)) {
            VStack {
                Image(book.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)

                RatingView(rating: book.rating)
                
                VStack(alignment: .leading) {
                    Text(book.title)
                        .font(.custom("Avenir-Heavy", size: 16))
                        .foregroundColor(Color(hex: "26344f"))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    Text(book.author)
                        .font(.custom("Avenir-Heavy", size: 14))
                        .foregroundColor(Color(hex: "26344f").opacity(0.7))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(.bottom, 10)
        }
    }
}

// MARK: -  Rating View
struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .foregroundColor(index < Int(rating) ? .yellow : Color(hex: "26344f").opacity(0.25))
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: -  AllBooks View
struct AllBooksView: View {
    let books: [Book]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(books) { book in
                        BookDisplayView(book: book)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("All Books")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("All Books")
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(Color(hex: "26344f"))
            }
        }
    }
}

// MARK: -  RecommendedBooks View
struct RecommendedBooksView: View {
    let books: [Book]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(books) { book in
                        BookDisplayView(book: book)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Recommended")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Recommended")
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(Color(hex: "26344f"))
            }
        }
    }
}

// MARK: -  PopularGenres View
struct PopularGenresView: View {
    let books: [Book]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 3)

                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(books) { book in
                        BookDisplayView(book: book)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .navigationTitle("Popular Genres")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Popular Genres")
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(Color(hex: "26344f"))
            }
        }
    }
}

// MARK: -  Preview
struct DiscoverBooks_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverBooks()
            .environmentObject(AuthViewModel())
            .environmentObject(BookManager())
    }
}
