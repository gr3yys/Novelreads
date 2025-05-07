//
// BookDetails.swift
// My App
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
// MARK: - Body
struct BookDetailsView: View {
    @State var tabIndex = 0
    @EnvironmentObject var bookManager: BookManager
    @State private var isBookmarked: Bool = false
    @State private var showingShelfList = false
    @State private var selectedShelf: String?
    let book: Book

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(book.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .padding()
                    .shadow(radius: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .bottom) {
                        Text(book.title)
                            .font(.custom("Avenir-Heavy", size: 20))
                            .foregroundColor(Color(hex: "26344f"))
                        
                        Spacer()
                        
                        // MARK: - Bookmark Action
                        Button(action: {
                            isBookmarked.toggle()
                            bookManager.toggleBookmark(for: book)
                                }) {
                                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(Color(hex: "698bcc"))
                                        .padding(.top, 8)
                                }
                    }

                    Text(book.author)
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(Color(hex: "26344f").opacity(0.7))

                    ratingView(for: book)

                    VStack {
                        CustomTopTabBar(tabIndex: $tabIndex)
                        
                        switch tabIndex {
                        case 0:
                            DescriptionView(book: book)
                        case 1:
                            ReviewsView(book: book)
                        case 2:
                            AboutAuthorView(book: book, allBooks: allBooks, recommendedBooks: recommendedBooks, popularBooks: popularBooks)

                        default:
                            EmptyView()
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 18)
                    .frame(width: UIScreen.main.bounds.width - 24, alignment: .center)
                }
            }
            .padding()
        }
        .navigationTitle("Overview")
        .toolbar {
                   ToolbarItem(placement: .navigationBarTrailing) {
                       Button(action: {
                           showingShelfList = true
                       }) {
                           Image(systemName: "plus.circle.fill")
                               .resizable()
                               .scaledToFit()
                               .frame(width: 24, height: 24)
                               .foregroundColor(Color(hex: "698bcc"))
                               .padding(.top, 8)
                       }
                   }
               }
               .onAppear {
                   // Initialize isBookmarked based on the book's bookmark status
                   isBookmarked = bookManager.isBookmarked(book)
               }
               .sheet(isPresented: $showingShelfList) {
                   ShelfListView(selectedShelf: $selectedShelf, onSelect: addBookToShelf)
               }
           }

           // MARK: - Add Book to Shelf Action
           private func addBookToShelf() {
               guard let shelf = selectedShelf else {
                   print("No shelf selected")
                   return
               }
               
               bookManager.addBook(to: shelf, book: book)
               print("Added \(book.title) to \(shelf) shelf")
           }


    // MARK: - Book Rating
    private func ratingView(for book: Book) -> some View {
        HStack {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(book.rating) ? "star.fill" : "star.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(index < Int(book.rating) ? .yellow : Color(hex: "26344f").opacity(0.25))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - DescriptionView
struct DescriptionView: View {
    let book: Book
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(displayedDescription)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(Color(hex: "26344f"))
                .lineLimit(isExpanded ? nil : 15)
                .animation(.easeInOut, value: isExpanded)
                .padding(.top, 8)

            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Text(isExpanded ? "read less" : "read more")
                        .foregroundColor(Color(hex: "698bcc"))
                        .font(.custom("Avenir-Medium", size: 16))
                }
            }

            DetailsSection(book: book)
            GenresSection(genres: book.genres)
        }
        .padding(.bottom)
    }

    // MARK: - Book Description
    private var displayedDescription: String {
        isExpanded ? book.description : String(book.description.prefix(500)) + "..."
    }
}

// MARK: -  ReviewsView
struct ReviewsView: View {
    let maxBarWidth: CGFloat = 300
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading) {
            // Overall rating
            Text(String(format: "%.1f", book.rating))
                .font(.custom("Avenir-Heavy", size: 24))
                .foregroundColor(Color(hex: "26344f"))
            
            // Rating stars
            HStack {
                ForEach(0..<5) { index in
                    Image(systemName: index < Int(book.rating) ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(index < Int(book.rating) ? .yellow : .gray)
                }
            }
            .padding(.top, -20)
            
            // MARK: -  Number of ratings
            Text("(\(book.numberOfRatings) ratings)")
                .font(.custom("Avenir", size: 14))
                .foregroundColor(Color(hex: "26344f"))
            
            // MARK: -  Ratings distribution
            VStack(alignment: .leading) {
                ForEach(1...5, id: \.self) { star in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(6 - star)")
                            .font(.custom("Avenir-Heavy", size: 16))
                            .foregroundColor(Color(hex: "26344f"))
                        Spacer()
                        
                        // Distribution bar
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(hex: "d9d9d9"))
                                .frame(width: maxBarWidth, height: 10)
                                .cornerRadius(5)
                            
                            Rectangle()
                                .fill(Color(hex: "698bcc"))
                                .frame(width: CGFloat(book.ratingsDistribution[star - 1]) / CGFloat(book.numberOfRatings) * maxBarWidth, height: 10)
                                .cornerRadius(5)
                        }
                    }
                    .padding(.top, 2)
                }
            }
            .padding(.top, 8)

            // MARK: -  Example reviews
            ForEach(sampleReviews) { review in
                ReviewCard(review: review)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
            }
        }
        .padding()
    }
}

// MARK: -  Sample review data
struct Review: Identifiable {
    let id = UUID()
    let username: String
    let rating: String
    let daysAgo: String
    let comment: String
}

// MARK: -  Sample reviews for demonstration
let sampleReviews: [Review] = [
    Review(username: "User1", rating: "★★★★☆", daysAgo: "5 days ago", comment: "did i finish the book ? or did the book finish me ?!? my gawwwwwd ! perfect ! perfect ! perfect ! everything down to the last minute detail ! this book felt heavenly."),
    Review(username: "User2", rating: "★★★☆☆", daysAgo: "10 days ago", comment: "It was okay, but not my favorite."),
    Review(username: "User3", rating: "★★★★★", daysAgo: "15 days ago", comment: "Absolutely loved it!"),
]

// MARK: -  ReviewCard View
struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
                .frame(height: 1)
                .background(Color(hex: "d9d9d9"))
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(review.username)
                        .font(.headline)
                    Text("\(review.rating)")
                        .font(.subheadline)
                        .foregroundColor(.yellow)
                }
                .padding()
                
                Spacer()
                
                Text(review.daysAgo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            Text(review.comment)
                .font(.body)
                .padding(.bottom, 10)
                .padding(.horizontal)
        }
    }
}

// MARK: -  books from author
struct AboutAuthorView: View {
    let book: Book
    let allBooks: [Book]
    let recommendedBooks: [Book]
    let popularBooks: [Book]

    // MARK: -  Combine and filter books here
    var otherBooks: [Book] {
        let combinedBooks = allBooks + recommendedBooks + popularBooks
        return combinedBooks.filter { $0.author == book.author && $0.id != book.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(book.about)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundColor(Color(hex: "26344f"))
            
            Text("More from this author")
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(Color(hex: "26344f"))
            
            if otherBooks.isEmpty {
                Text("No other books available from this author.")
                    .font(.custom("Avenir-Regular", size: 14))
                    .foregroundColor(Color(hex: "26344f"))
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(otherBooks) { otherBook in
                            NavigationLink(destination: BookDetailsView(book: otherBook)){
                                VStack {
                                    Image(otherBook.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .clipped()
                                        .frame(width: 100, height: 150)
                                        .shadow(color: Color(hex: "26344f").opacity(0.25), radius: 5, x: 0, y: 2)
                                    
                                    Text(otherBook.title)
                                        .font(.custom("Avenir-Bold", size: 16))
                                        .foregroundColor(Color(hex: "26344f"))
                                        .multilineTextAlignment(.leading)
                                        .frame(width: 100)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .onAppear {
            // Print for debugging
            print("All books: \(allBooks)")
            print("Recommended books: \(recommendedBooks)")
            print("Popular books: \(popularBooks)")
            print("Other books: \(otherBooks)")
        }
    }
}




// MARK: -  Top Tab Bar
struct CustomTopTabBar: View {
    @Binding var tabIndex: Int

    var body: some View {
        HStack(spacing: 20) {
            TabBarButton(text: "Description", isSelected: tabIndex == 0) {
                onButtonTapped(index: 0)
            }
            TabBarButton(text: "Reviews", isSelected: tabIndex == 1) {
                onButtonTapped(index: 1)
            }
            TabBarButton(text: "About this author", isSelected: tabIndex == 2) {
                onButtonTapped(index: 2)
            }
            Spacer()
        }
    }

    private func onButtonTapped(index: Int) {
        withAnimation { tabIndex = index }
    }
}

// MARK: -  TabBarButton
struct TabBarButton: View {
    let text: String
    var isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(text)
            .fontWeight(isSelected ? .heavy : .regular)
            .font(.custom("Avenir", size: 16))
            .foregroundColor(Color(hex: "26344f"))
            .padding(.bottom, 10)
            .onTapGesture { onTap() }
            .border(width: isSelected ? 2 : 0, edges: [.bottom], color: Color(hex: "698bcc"))
    }
}

// MARK: -  EdgeBorder
struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            let x: CGFloat
            let y: CGFloat
            let w: CGFloat
            let h: CGFloat

            switch edge {
            case .top:
                x = rect.minX
                y = rect.minY
                w = rect.width
                h = width
            case .bottom:
                x = rect.minX
                y = rect.maxY - width
                w = rect.width
                h = width
            case .leading:
                x = rect.minX
                y = rect.minY
                w = width
                h = rect.height
            case .trailing:
                x = rect.maxX - width
                y = rect.minY
                w = width
                h = rect.height
            }
            path.addRect(CGRect(x: x, y: y, width: w, height: h))
        }
        return path
    }
}

// MARK: -  DetailsSection
struct DetailsSection: View {
    let book: Book

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Details")
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(Color(hex: "26344f"))

            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Pages").font(.custom("Avenir-Heavy", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text("Publisher").font(.custom("Avenir-Heavy", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text("ISBN").font(.custom("Avenir-Heavy", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text("Released").font(.custom("Avenir-Heavy", size: 15)).foregroundColor(Color(hex: "26344f"))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("\(book.pages)").font(.custom("Avenir-Medium", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text(book.publisher).font(.custom("Avenir-Medium", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text(book.isbn).font(.custom("Avenir-Medium", size: 15)).foregroundColor(Color(hex: "26344f"))
                    Text(book.released).font(.custom("Avenir-Medium", size: 15)).foregroundColor(Color(hex: "26344f"))
                }
            }
            .padding(.bottom)
        }
    }
}

// MARK: - GenresSection
struct GenresSection: View {
    let genres: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Genres")
                .font(.custom("Avenir-Heavy", size: 18))
                .foregroundColor(Color(hex: "26344f"))
            HStack {
                ForEach(genres, id: \.self) { genre in
                    Text(genre)
                        .padding(10)
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(Color(hex: "26344f"))
                        .background(
                            RoundedRectangle(cornerRadius: 35)
                                .stroke(Color(hex: "698bcc"), lineWidth: 1)
                        )
                }
            }
        }
    }
}

// MARK: -  Preview
#Preview {
    BookDetailsView(book: Book(id: UUID(), imageName: "rv", title: "Ruthless Vows", author: "Rebecca Ross", rating: 4.5, description: "The epic conclusion to the intensely romantic and beautifully written story that started in Divine Rivals. \n\nTwo weeks have passed since Iris Winnow returned home bruised and heartbroken from the front, but the war is far from over. Roman is missing, and the city of Oath continues to dwell in a state of disbelief and ignorance. When Iris and Attie are given another chance to report on Dacre’s movements, they both take the opportunity and head westward once more despite the danger, knowing it’s only a matter of time before the conflict reaches a city that’s unprepared and fracturing beneath the chancellor’s reign. \n\nSince waking below in Dacre’s realm, Roman cannot remember his past. But given the reassurance that his memories will return in time, Roman begins to write articles for Dacre, uncertain of his place in the greater scheme of the war. When a strange letter arrives by wardrobe door, Roman is first suspicious, then intrigued. As he strikes up a correspondence with his mysterious pen pal, Roman will soon have to make a decision: to stand with Dacre or betray the god who healed him. And as the days grow darker, inevitably drawing Roman and Iris closer together…the two of them will risk their very hearts and futures to change the tides of the war.", pages: 419, publisher: "Magpie", isbn: "0008588236", released: "December 26, 2023", genres: ["Historical Fiction", "Romance", "Fantasy"], numberOfRatings: 504318, ratingsDistribution: [318000,150000,30000,5000,33018], about: "Rebecca Ross is the #1 New York Times and Sunday Times bestselling author of fantasy books for teens and adults. She has written multiple highly acclaimed duologies, including LETTERS OF ENCHANTMENT, ELEMENTS OF CADENCE, and THE QUEEN’S RISING as well as two standalone novels: DREAMS LIE BENEATH and SISTERS OF SWORD & SONG. When not writing, she can be found in her garden where she plants wildflowers and story ideas. She resides in Northeast Georgia with her husband and her dog."))
    
        .environmentObject(BookManager())
}
